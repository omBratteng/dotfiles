# pd

A zsh plugin for fast directory navigation in a structured workspace, with optional auto-cloning from your SCM of choice.

If your dev folder follows a `<root>/<workspace>/<project>/<repo>` layout, then `pd foo<TAB>` jumps you straight to the matching repo. If the repo doesn't exist yet, `pd` (or `p`) can clone it for you.

## Features

- `p` and `pd` commands for jumping into project directories, each with **independent SCM/clone config**
- Tab completion with substring matching (`pd foo<TAB>` matches `myorg/foo-service`)
- Configurable scan depth and "leaf" markers (e.g. stop descending at `.git`)
- Optional auto-clone for missing repos via Bitbucket DC, GitHub, GitLab, or a custom URL template
- Interactive y/N confirmation before cloning (toggleable)
- Colored output that respects non-TTY environments

<!--
## Installation

### oh-my-zsh

```bash
git clone <this-repo> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pd
```

Add `pd` to your `plugins=(...)` list in `~/.zshrc`.

### Manual

```zsh
source /path/to/pd.plugin.zsh
```
-->

## Quick start

Assume the following layout:

```text
~/Developer/
  personal/
    myorg/
      foo-service/
      bar-cli/
  work/
    acme/
      api-gateway/
      web-frontend/
```

Configure in `~/.zshrc`, before the plugin is loaded:

```zsh
_PD_DIR=~/Developer        # auto-detected: /srv on Linux, ~/Developer on macOS
_PD_WORK_DIR=work          # subdirectory used by `pd`
```

Then:

```zsh
p personal/myorg/foo-service   # cd into ~/Developer/personal/myorg/foo-service
pd acme/api-gateway            # cd into ~/Developer/work/acme/api-gateway
pd api<TAB>                    # completes to pd acme/api-gateway/
```

## Commands

| Command | Description |
| --- | --- |
| `p <path>` | `cd` into `$_PD_DIR/<path>` |
| `pd <path>` | `cd` into `$_PD_DIR/$_PD_WORK_DIR/<path>` |

Both support tab completion. When auto-clone is enabled for the corresponding scope, a missing path of the form `<project>/<repo>` will be cloned before `cd`'ing in.

## Configuration

All options are environment variables. Set them in `~/.zshrc` before the plugin is sourced (or export them ahead of time).

### Shared (apply to both `p` and `pd`)

| Variable | Default | Description |
| --- | --- | --- |
| `_PD_DIR` | `/srv` (Linux), `~/Developer` (macOS) | Root workspace directory |
| `_PD_WORK_DIR` | _(unset)_ | Subdir under `_PD_DIR` that `pd` operates in. Required for `pd`. |
| `_PD_DEPTH` | `3` | Max directory depth to scan for completions |
| `_PD_STOP_AT` | `.git` | Colon-separated entries that mark a leaf directory. Example: `.git:docker-compose.yml` |

### Per-command SCM / auto-clone

> [!NOTE]
> Each command has its own independent set of SCM and clone settings:
>
> - Variables prefixed `_P_*` apply to the **`p`** command
> - Variables prefixed `_PD_*` apply to the **`pd`** command

| `p` variable | `pd` variable | Default | Description |
| --- | --- | --- | --- |
| `_P_CLONE` | `_PD_CLONE` | `0` | `1` to enable auto-clone of missing repos |
| `_P_CLONE_PROMPT` | `_PD_CLONE_PROMPT` | `1` | `1` to confirm interactively before cloning |
| `_P_CLONE_ARGS` | `_PD_CLONE_ARGS` | _(empty)_ | Extra args passed to `git clone`, e.g. `"--depth 1 --single-branch"` |
| `_P_SCM` | `_PD_SCM` | _(empty)_ | One of: `bitbucket-dc`, `github`, `gitlab`, `generic` |
| `_P_SCM_HOST` | `_PD_SCM_HOST` | _(empty)_ | SCM host, e.g. `github.com` |
| `_P_SCM_PROTO` | `_PD_SCM_PROTO` | `ssh` | `ssh` or `https` |
| `_P_SCM_SSH_USER` | `_PD_SCM_SSH_USER` | `git` | SSH user |
| `_P_SCM_SSH_PORT` | `_PD_SCM_SSH_PORT` | _(empty)_ | SSH port (Bitbucket DC typically `7999`) |
| `_P_SCM_URL_TEMPLATE` | `_PD_SCM_URL_TEMPLATE` | _(empty)_ | URL template for `*_SCM=generic` |

> [!IMPORTANT]
> Auto-clone is **disabled by default** in both scopes. Enable per scope with `_P_CLONE=1` and/or `_PD_CLONE=1`.

If clone is enabled but required vars are missing, you get a clear error rather than a malformed URL.

## Examples

### Different SCMs for `p` and `pd`

Personal repos via GitHub (`p`), work repos via Bitbucket DC (`pd`):

```zsh
# Personal stuff via `p`
_P_CLONE=1
_P_SCM=github
_P_SCM_HOST=github.com

# Work stuff via `pd`
_PD_WORK_DIR=work
_PD_CLONE=1
_PD_SCM=bitbucket-dc
_PD_SCM_HOST=git.work.example
_PD_SCM_SSH_PORT=7999
```

Now `p myname/dotfiles` clones from GitHub, `pd myproj/api-gateway` clones from Bitbucket.

### Bitbucket Data Center

```zsh
_PD_CLONE=1
_PD_SCM=bitbucket-dc
_PD_SCM_HOST=git.example.com
_PD_SCM_SSH_PORT=7999
```

Cloning `pd myproj/new-repo` produces:

```text
ssh://git@git.example.com:7999/myproj/new-repo.git
```

### GitHub

```zsh
_P_CLONE=1
_P_SCM=github
_P_SCM_HOST=github.com
```

`p myorg/some-repo` -> `git@github.com:myorg/some-repo.git`

### Self-hosted GitLab over HTTPS

```zsh
_PD_CLONE=1
_PD_SCM=gitlab
_PD_SCM_HOST=gitlab.example.com
_PD_SCM_PROTO=https
```

### Generic / custom

```zsh
_PD_CLONE=1
_PD_SCM=generic
_PD_SCM_URL_TEMPLATE='ssh://{user}@{host}:{port}/scm/{project}/{repo}.git'
_PD_SCM_HOST=git.example.com
_PD_SCM_SSH_PORT=2222
```

Available placeholders: `{proto}`, `{user}`, `{host}`, `{port}`, `{project}`, `{repo}`.

### One-off overrides

Any variable can be set per-invocation:

```zsh
_PD_CLONE=1 _PD_CLONE_ARGS="--depth 1" pd myorg/big-monorepo
_P_CLONE_PROMPT=0 p myorg/another-repo   # skip the y/N for `p`
```

## Completion behavior

Tab completion uses substring matching:

```text
pd foo<TAB>       -> pd myorg/foo-service/
pd api<TAB>       -> all matching repos
pd myorg/<TAB>    -> all repos under myorg/
```

Directories containing any entry from `_PD_STOP_AT` (default: `.git`) are treated as leaves; the completer won't descend into them, keeping things fast even with hundreds of repos.

> [!NOTE]
> `_PD_DEPTH` and `_PD_STOP_AT` are shared between `p` and `pd`.

## Tips

- Use shallow clones for big repos: `_PD_CLONE_ARGS="--depth 1"`
- If your SCM project keys are uppercase but you prefer lowercase paths locally, use `*_SCM=generic` with a template that suits your layout
- The plugin sets `GIT_TERMINAL_PROMPT=0` and `SSH_ASKPASS_REQUIRE=never` during clone to fail fast on auth issues instead of hanging

## Troubleshooting

**"`<path>` not found (set `_PD_CLONE=1` to auto-clone)"**
Auto-clone is disabled for that scope. Set `_P_CLONE=1` (for `p`) or `_PD_CLONE=1` (for `pd`), along with a valid `*_SCM` config.

**"cannot clone, unset: `_PD_SCM_HOST` ..."**
Required SCM variables are missing for the selected scope's `*_SCM`. See the table above. The error names the exact variable for the scope you're in.

**"`<path>` is not `<project>/<repo>`"**
Auto-clone only handles two-segment paths. Top-level dirs (no `/`) and deeper paths aren't cloned.

**Colors don't show up**
Colors are gated on `tput colors >= 8` and a TTY. They initialize lazily on first message, so plugin-load-time conditions don't matter. If you still don't see them, check `echo $TERM` (should not be `dumb`).

<!--
## License

MIT (or whatever you prefer).
-->
