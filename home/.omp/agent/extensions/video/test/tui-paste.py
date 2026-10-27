"""Exercise native pasted-video chips in the installed omp TUI (no clipboard mutation)."""
import fcntl
import http.server
import json
import os
import pathlib
import pty
import select
import struct
import subprocess
import sys
import tempfile
import termios
import threading
import time

requests = []
received = threading.Event()


class Server(http.server.BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        requests.append(body)
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.end_headers()
        chunk = {"id": "test", "object": "chat.completion.chunk", "created": 0,
                 "model": body["model"], "choices": [{"index": 0,
                 "delta": {"role": "assistant", "content": "Video received."}, "finish_reason": None}]}
        self.wfile.write(("data: " + json.dumps(chunk) + "\n\n").encode())
        chunk["choices"][0].update(delta={}, finish_reason="stop")
        self.wfile.write(("data: " + json.dumps(chunk) + "\n\ndata: [DONE]\n\n").encode())
        self.wfile.flush()
        received.set()


server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Server)
threading.Thread(target=server.serve_forever, daemon=True).start()
try:
    with tempfile.TemporaryDirectory(prefix="omp-video-tui-", dir="/tmp/opencode") as work:
        root = pathlib.Path(work)
        agent = root / "agent"
        agent.mkdir()
        (agent / "config.yml").write_text("setupVersion: 2\nstartup:\n  quiet: true\n  showSplash: false\n")
        (agent / "models.yml").write_text(f"""providers:
  vllm:
    baseUrl: http://127.0.0.1:{server.server_port}/v1
    api: openai-completions
    apiKey: test
    models:
      - id: qwen3.8-flash-next
        name: Test video
        input: [text, image]
        contextWindow: 32768
        maxTokens: 128
""")
        clip = root / "clip.mp4"
        subprocess.run(["ffmpeg", "-v", "error", "-f", "lavfi", "-i", "color=c=red:s=64x64:d=1", "-c:v", "libx264", str(clip)], check=True)
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 140, 0, 0))
        extension = pathlib.Path(__file__).resolve().parent.parent / "index.ts"
        p = subprocess.Popen(["omp", "--no-extensions", "-e", str(extension), "--no-skills", "--no-rules", "--no-tools", "--no-title", "--thinking", "off", "--model", "vllm/qwen3.8-flash-next"],
                             cwd=root, env=dict(os.environ, PI_CODING_AGENT_DIR=str(agent), TERM="xterm-256color"),
                             stdin=slave, stdout=slave, stderr=slave, start_new_session=True)
        os.close(slave)
        output = b""
        try:
            start = time.monotonic()
            pasted = submitted = False
            while time.monotonic() - start < 20 and not received.is_set():
                if select.select([master], [], [], 0.05)[0]:
                    try:
                        data = os.read(master, 65536)
                    except OSError:
                        break
                    output += data
                    if b"\x1b[6n" in data:
                        os.write(master, b"\x1b[1;1R")
                    if b"\x1b[c" in data:
                        os.write(master, b"\x1b[?1;2c")
                # Paste through the terminal's real bracketed-paste path, not an
                # artificial image object; wait for the preview before Enter.
                if not pasted and time.monotonic() - start > 2:
                    prefix = b"" if "--plain" in sys.argv else b"/video "
                    os.write(master, prefix + b"\x1b[200~" + str(clip).encode() + b"\x1b[201~")
                    pasted = True
                if pasted and not submitted and b"#1" in output:
                    question = b" What happened in this video?\r" if "--plain" in sys.argv else b" --What happened in this video?\r"
                    os.write(master, question)
                    submitted = True
            if not requests:
                raise AssertionError(f"No provider request; pasted={pasted}, submitted={submitted}; terminal tail={output[-4000:]!r}")
            videos = [block for message in requests[-1]["messages"]
                      if isinstance(message.get("content"), list)
                      for block in message["content"] if block.get("type") == "video_url"]
            assert len(videos) == 1, "Native video chip did not become video_url"
            assert videos[0]["video_url"]["url"].startswith("data:video/mp4;base64,")
            print("PASS: installed omp TUI native pasted chip sends original video_url" + (" (without /video)" if "--plain" in sys.argv else " (with /video)"))
        finally:
            p.terminate()
            try:
                p.wait(timeout=5)
            except subprocess.TimeoutExpired:
                p.kill()
                p.wait()
            os.close(master)
finally:
    server.shutdown()
    server.server_close()
