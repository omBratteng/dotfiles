# zsh-plugin-pipx

This plugin adds completion for [pipx](https://github.com/pypa/pipx).

To use it, add `zsh-plugin-pipx` to the plugins array in your zshrc file:

```shell
plugins=(... zsh-plugin-pipx)
```

This plugin does not add any aliases.

## Cache

This plugin caches the completion script and is automatically updated when the plugin is loaded, which is usually when you start up a new terminal emulator.

The cache is stored at:

- `$ZSH_CACHE_DIR/completions/_pipx` completions script
