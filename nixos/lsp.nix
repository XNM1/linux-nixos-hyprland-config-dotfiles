{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313Packages.python-lsp-server
    ty
    ruff
    nodePackages_latest.nodemon
    nodePackages_latest.typescript
    nodePackages_latest.typescript-language-server
    eslint
    biome
    rubyPackages.htmlbeautifier
    nodePackages_latest.vscode-langservers-extracted
    superhtml
    jsonnet-language-server
    nodePackages_latest.yaml-language-server
    taplo #toml formatter & lsp
    tombi
    nodePackages_latest.bash-language-server
    nodePackages_latest.graphql-language-service-cli
    dockerfile-language-server
    vue-language-server
    lua-language-server
    marksman
    markdown-oxide
    nil
    nixd
    zls
    gopls
    delve
    emmet-language-server
    buf
    protols
    cmake-language-server
    neocmakelsp
    just-lsp
    docker-compose-language-service
    vscode-extensions.vadimcn.vscode-lldb
    slint-lsp
    terraform-ls
    hyprls
    helix-gpt
    copilot-language-server
    fish-lsp
    wasm-language-tools
  ];  
}
