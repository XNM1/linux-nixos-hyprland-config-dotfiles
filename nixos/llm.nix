{ pkgs, ... }:

{
  services.ollama.enable = true;
  services.ollama.loadModels = [ "llama3.2:3b" "llama3.2-vision:11b" "phi4:14b" "qwq:32b" "dolphin3:8b" "smallthinker:3b" "nomic-embed-text" ];
  services.ollama.acceleration = "cuda";
  
  environment.systemPackages = with pkgs; [
    oterm
    open-webui
    alpaca
    nextjs-ollama-llm-ui

    aichat
    aider-chat

    tgpt
    smartcat
  ];
}
