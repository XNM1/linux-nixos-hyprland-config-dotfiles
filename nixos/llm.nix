{ pkgs, config, ... }:

{

  services.ollama = {
    enable = true;
    loadModels = [
      # small/laptop (multimodal, audio on E2B/E4B)
      "gemma4:e2b"                              # 4.6 GB
      "gemma4:e4b"                              # 6.6 GB
      # medium ~27B, 2-bit Qwen3.8-27B (Ollama-runnable stand-in for
      # Bonsai 2 / Saluki, which need Prism's llama.cpp fork / Underdog engine)
      "hf.co/unsloth/Qwen3.8-27B-GGUF:UD-IQ2_XXS"  # 7.27 GB
      # medium, max quality: q4 17.7 GB, CPU-offloaded; hybrid linear
      # attention (48/64 layers) keeps KV small so it stays usable
      "qwen3.8:27b"
      # multimodal MoE, 35B total / 3B active, q4 (ollama.com/openbmb/minicpm-v4.7)
      "openbmb/minicpm-v4.7:35b-a3b"            # 22 GB
      # System One (Jev-like) open decision models, /v1/systemone (Ollama >= 0.35)
      "nimble:9b"                               # Bespoke Labs, 9B
      "laya"                                    # Convai 421M, Apache 2.0
      # embeddings
      "qwen3-embedding:8b"                      # 4.7 GB q4
      "embeddinggemma"                          # 622 MB, 300M
    ];
    syncModels = true;
    package = pkgs.ollama-cuda;
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 7777;
        bind_address = "127.0.0.1";
        secret_key = "@SEARX_SECRET_KEY@"; # FIXME: Set up this key in the .env file described below, name of variable `SEARX_SECRET_KEY`
      };
      search = {
        formats = [ "html" "json" ];
      };
    };
    environmentFile = "${config.users.users.xnm.home}/.config/.env.searxng"; # FIXME: The location of the `.env` file where you need to set up the key
  };

  services.n8n = {
    enable = false;
  };

  systemd.services.n8n = {
    serviceConfig = {
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };

  services.open-webui = {
    enable = false;
    port = 8888;
    host = "127.0.0.1";
  };

  environment.systemPackages = with pkgs; [
    nix-ai-tools.backlog-md
    # nix-ai-tools.beads-rust
    nix-ai-tools.tuicr
    nix-ai-tools.mcporter
    nix-ai-tools.rtk

    omp
    herdr

    oterm
    # alpaca

    aichat
    gum # Progress UI for the fish AIChat bindings
    pay-respects
    fabric-ai

    # aider-chat
    # nix-ai-tools.pi
    # nix-ai-tools.ccusage-pi
    nix-ai-tools.ccusage
    nix-ai-tools.opencode2
    nix-ai-tools.openspec
    nix-ai-tools.openskills
    # nix-ai-tools.codex

    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui

    chromium
    # google-chrome

    nix-ai-tools.agent-browser

    # playwright-mcp
    # mcp-nixos
    # mcp-k8s-go
    # github-mcp-server
  ];
}
