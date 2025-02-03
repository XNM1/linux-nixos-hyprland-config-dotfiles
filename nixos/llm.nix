{ pkgs, ... }:

{

  services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:3b" "llama3.2-vision:11b" "phi4:14b" "deepseek-r1:7b" "dolphin3:8b" "smallthinker:3b" "nomic-embed-text" ];
    acceleration = "cuda";
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 7777;
        bind_address = "127.0.0.1";
        secret_key = "your_key_here"; # FIXME: generate and paste your custom key here
      };
    };
  };

  services.open-webui = {
    enable = true;
    port = 8888;
    host = "127.0.0.1";
  };
  
  environment.systemPackages = with pkgs; [
    oterm
    alpaca
    aichat
    aider-chat

    # tgpt
    # smartcat
    # nextjs-ollama-llm-ui
    # open-webui
  ];
}
