{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313Packages.python-lsp-server
    ty
    ruff
    nodemon
    typescript
    typescript-language-server
    eslint
    biome
    rubyPackages.htmlbeautifier
    vscode-langservers-extracted
    superhtml
    jsonnet-language-server
    yaml-language-server
    taplo #toml formatter & lsp
    tombi
    bash-language-server
    graphql-language-service-cli
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
    nix-ai-tools.copilot-language-server
    lsp-ai
    fish-lsp
    wasm-language-tools
  ];  
}
