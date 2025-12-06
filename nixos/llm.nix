{ inputs, pkgs, config, ... }:

{

  services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:3b" "phi4-reasoning:14b" "dolphin3:8b" "second_constantine/gpt-oss-u:20b" "smallthinker:3b" "gemma3n:e4b" "gemma3:4b" "deepcoder:14b" "qwen3:14b" "qwen3-coder:30b" "gpt-oss:20b" "nomic-embed-text" ];
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
    enable = true;
  };

  systemd.services.n8n = {
    serviceConfig = {
      Environment = "PATH=/run/current-system/sw/bin";
    };
  };

  # services.open-webui = {
  #   enable = true;
  #   port = 8888;
  #   host = "127.0.0.1";
  # };
  
  environment.systemPackages = with pkgs; [
    inputs.nix-ai-tools.packages.${pkgs.system}.backlog-md

    oterm
    # alpaca

    aichat
    fabric-ai

    # aider-chat
    inputs.nix-ai-tools.packages.${pkgs.system}.opencode
    inputs.nix-ai-tools.packages.${pkgs.system}.openspec
    inputs.nix-ai-tools.packages.${pkgs.system}.openskills
    # codex

    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui

    chromium
    # playwright
  ];
}
