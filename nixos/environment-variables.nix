{ config, pkgs, ... }:

{
  # Setup Env Variables
  environment.variables.SPOTIFY_PATH = "${pkgs.spotify}/";
  environment.variables.JDK_PATH = "${pkgs.jdk17}/";
  environment.variables.NODEJS_PATH = "${pkgs.nodejs}/";
  environment.variables.ANDROID_SDK_ROOT = "${config.users.users.xnm.home}/android-sdk";
  # colgrep encoder: CUDA ONNX variant ships an ubuntu binary that dies on NixOS;
  # the 110M ColBERT is fine on CPU. Agent (2B llama.cpp) still uses the 4070 via Vulkan.
  environment.variables.NEXT_PLAID_FORCE_CPU = "1";
  environment.variables.ANDROID_AVD_HOME = "${config.users.users.xnm.home}/.android/avd";
}
