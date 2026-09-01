# Vendored oh-my-zsh

These files are copied verbatim out of [oh-my-zsh][omz] so the useful parts
survive without the framework. Do not hand-edit them: change them upstream, or
record the deviation in the "Local changes" table below and in the file header.

- **Upstream:** <https://github.com/ohmyzsh/ohmyzsh>
- **Commit:** `ff1df9a0399d56b9f6e957bb62a2d4ba6bc0ef4c` (2026-06-25)

## Layout

| Path                | Loaded by            | When                                    |
| ------------------- | -------------------- | --------------------------------------- |
| `lib/*.zsh`         | `S30_vendor_lib`     | after compinit, numbered for load order |
| `plugins/*.zsh`     | `S40_vendor_plugins` | after the libs                          |
| `plugins/completions/` | `plugins/docker.zsh` | not sourced; `_docker` fallback for pre-23.0 docker |
| `completions/*`     | `$fpath`             | added by `S28_compinit`, before compinit |

`completions/` holds the completion functions that upstream ships *next to* a
plugin rather than inside it. oh-my-zsh put every plugin directory on `$fpath`,
so they came along for free; here they have to be collected explicitly.
`_terraform`, `_pip` and `_docker-compose` are the ones that matter —
`_golang` and `_yarn` were deliberately left behind because zsh-completions
ships better-maintained versions of both.

Not carried over: `plugins/colored-man-pages/nroff` (a Solaris-only shim the
plugin only puts on `$PATH` when `$OSTYPE` is `solaris*`) and
`plugins/golang/templates/` (dead files, nothing references them).

`../disabled/gpg-agent` is a long-diverged fork of the upstream `gpg-agent`
plugin. It is not loaded — `SSH_AUTH_SOCK` points at the 1Password agent — and
is kept outside `vendor/` because it is no longer upstream code.

`lib/` is numbered because `00-functions.zsh` defines `env_default`, `take` and
`omz_urlencode`, which the later files and `S31_misc` depend on.

## What was dropped, and why

Everything below was enabled at some point but had zero recorded uses across
156k shell history entries, or only existed to serve oh-my-zsh itself:

- **Plugins:** `macos`, `iterm2`, `aws`, `vscode`, `bazel`, `aliases`, `gh`,
  `1password`, `kubectx`. The last four were completion-only; homebrew already
  ships `_gh`, `_op` and `_aws` in `site-functions`, and `kubectx` only supplied
  `kubectx_prompt_info`, which this powerlevel10k config never referenced.
- **Libs:** `cli.zsh` (the `omz` command), `diagnostics.zsh`, `compfix.zsh`,
  `spectrum.zsh`, `bzr.zsh`, `nvm.zsh`, `correction.zsh` (needs
  `ENABLE_CORRECTION`, never set), `clipboard.zsh` (only the dropped plugins
  used it), and the prompt plumbing — `git.zsh`, `vcs_info.zsh`,
  `async_prompt.zsh`, `prompt_info_functions.zsh` — which powerlevel10k
  replaces wholesale.

## Local changes

| File                   | Change                                                                                                                 |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `lib/00-functions.zsh` | Subset of `lib/functions.zsh`. Kept `zsh_stats`, the `take` family, `default`, `env_default`, `omz_urlencode`. Dropped `uninstall_oh_my_zsh`, `upgrade_oh_my_zsh`, `open_command`, `alias_value`, `try_alias_value`, `omz_urldecode`. |
| `lib/05-git.zsh`       | Subset of `lib/git.zsh`. Kept `__git_prompt_git`, `git_current_branch` (14 git-plugin aliases call it), `git_previous_branch`, `git_current_user_name`, `git_current_user_email`, `git_repo_name`. Dropped every prompt-building helper. |
| `lib/30-completion.zsh`| Dropped the `CASE_SENSITIVE` / `HYPHEN_INSENSITIVE` branches and inlined the default `matcher-list`. Dropped the trailing `bashcompinit`, which now lives in `S28_compinit`. |
| `lib/50-theme-and-appearance.zsh` | `diff --color` capability probe deferred via `zsh-defer` so its fork stays off the startup path. The ls-colour probes below it are skipped at runtime by `S26_tool-gates.zsh` setting `DISABLE_LS_COLORS` when eza owns `ls`. |
| `plugins/docker.zsh` | Background completion generator gated on `_docker` missing or older than 24h (day gate mirrors `S28_compinit`); upstream ran `docker --version` (~200ms) and `docker completion zsh` on every shell. |

Every other file is byte-identical to upstream below its header block.

## Refreshing

```sh
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh /tmp/omz
diff /tmp/omz/plugins/git/git.plugin.zsh <(tail -n +9 .config/zsh.d/vendor/plugins/git.zsh)
```

Apply anything worth having, then bump the commit hash above and in each file
header. The two files in the "Local changes" table need re-patching by hand.

[omz]: https://github.com/ohmyzsh/ohmyzsh
