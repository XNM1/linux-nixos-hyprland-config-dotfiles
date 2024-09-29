{ pkgs, ... }:

{
  services.ollama.enable = true;
  services.ollama.loadModels = [ "llama3.2" ];
  services.ollama.acceleration = "cuda";

  services.nextjs-ollama-llm-ui.enable = true;
  services.nextjs-ollama-llm-ui.port = 5000;
}
