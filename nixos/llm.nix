{ pkgs, config, ... }:

{

  services.ollama = {
    enable = true;
    loadModels = [ "gemma4:e2b" "gemma4:e4b" "gpt-oss:20b" "jaahas/qwen3.5-uncensored:4b" "jaahas/qwen3.5-uncensored:9b" "devstral-small-2:24b" "glm-4.7-flash" "nomic-embed-text-v2-moe" "x/z-image-turbo" "x/flux2-klein:4b" "x/flux2-klein:9b" ];
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
    nix-ai-tools.beads-rust
    nix-ai-tools.tuicr
    nix-ai-tools.mcporter
    nix-ai-tools.rtk

    oterm
    # alpaca

    aichat
    fabric-ai

    # aider-chat
    # nix-ai-tools.pi
    # nix-ai-tools.ccusage-pi
    nix-ai-tools.ccusage-opencode
    nix-ai-tools.opencode
    nix-ai-tools.openspec
    nix-ai-tools.openskills
    # nix-ai-tools.codex

    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui

    chromium
    # playwright

    nix-ai-tools.agent-browser
  ];
}
