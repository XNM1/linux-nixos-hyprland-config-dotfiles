{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python311Packages.python-lsp-server
    nodePackages_latest.nodemon
    nodePackages_latest.typescript
    nodePackages_latest.typescript-language-server
    nodePackages_latest.vscode-langservers-extracted
    nodePackages_latest.yaml-language-server
    nodePackages_latest.dockerfile-language-server-nodejs
    nodePackages_latest.bash-language-server
    nodePackages_latest.graphql-language-service-cli
    vue-language-server
    sumneko-lua-language-server
    marksman
    markdown-oxide
    nil
    zls
    gopls
    delve
    emmet-language-server
    buf-language-server
    cmake-language-server
    docker-compose-language-service
    vscode-extensions.vadimcn.vscode-lldb
    slint-lsp
    terraform-ls
    ansible-language-server
    hyprls
    helix-gpt
  ];  
}
