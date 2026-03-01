# Claude Dev Environment Automation

Ansible playbook for provisioning Claude CLI dev environments on Rocky Linux ARM64 servers.

## Quick Reference

```bash
# Deploy to all servers
ansible-playbook -i inventory.ini playbook.yml

# Deploy specific component
ansible-playbook -i inventory.ini playbook.yml --tags cl
ansible-playbook -i inventory.ini playbook.yml --tags motd,templates

# Dry run
ansible-playbook -i inventory.ini playbook.yml --check --diff
```

## Architecture

- **Single playbook** (`playbook.yml`) with tagged tasks — no roles
- **Jinja2 templates** in `templates/` deployed to server paths
- **Two users**: `root` (Ansible target) and `dev` (Claude CLI, docker)
- **`cl` session manager** (`templates/cl.sh.j2`) orchestrates Claude CLI inside tmux
- **Variables** at top of `playbook.yml` (versions, paths, permissions)

## Project Structure

```
├── playbook.yml                         # All tasks, tagged
├── inventory.ini.example                # Template — copy to inventory.ini
└── templates/
    ├── cl.sh.j2                         # cl session manager (~680 lines)
    ├── tmux-cl.conf.j2                  # tmux config for cl
    ├── motd.sh.j2                       # Login MOTD
    ├── README.txt.j2                    # ~/README.txt on server
    ├── new-project.sh.j2               # /src/templates/new-project.sh
    └── docker-compose.template.yml.j2  # Docker compose template
```

## Playbook Tags

| Tag | Scope |
|-----|-------|
| `system` | OS update, EPEL |
| `tools` | git, tmux, htop, curl, wget |
| `docker` | Docker CE + Compose |
| `node` | NVM + Node.js LTS |
| `python` | Python 3 + pip |
| `go` | Go (ARM64) |
| `claude` | Claude CLI + plugins + claude-gc |
| `plugins` | Claude Code plugins only |
| `claude-gc` | claude-gc only |
| `cl` | cl session manager + tmux config (also: `claunch` for backward compat) |
| `dirs` | /src directory |
| `templates` | README.txt, new-project.sh, docker-compose template |
| `motd` | Login MOTD |
| `config` | .bashrc PATH setup |
| `git` | Git user config |
| `user` | All dev user tasks |
| `verify` | Version checks |

## Key Variables

```yaml
cl_default_permission_mode: "skip"  # "skip" | "acceptEdits"
claude_plugins: [...]               # List of Claude Code plugins to install
nvm_version: "0.40.1"
go_version: "1.23.4"
dev_user: "dev"
src_dir: "/src"
```

## Conventions

- Templates use `.j2` extension, deployed paths drop it
- Tags on every task — `[component]` or `[component, user]` for dev-user tasks
- Migration/cleanup tasks use `changed_when: false` for idempotency
- `cl` tag also includes `claunch` for backward compat with existing automation

## Verification

```bash
# Syntax check the cl script template (render Jinja2 first)
bash -n test/cl.sh

# Docker-based functional test
./test/run-test.sh

# Ansible dry run
ansible-playbook -i inventory.ini playbook.yml --check --diff
```

## Gotchas

- Claude CLI cannot run as root — always target `dev` user for Claude tasks
- `cl.sh.j2` uses `set -eo pipefail` — arithmetic expressions returning 0 cause exit (use `++var` not `var++`)
- `--tags claunch` still works (dual-tagged) but `claunch` binary is removed on deploy
- `cl -w` requires a git repository — delegates to `claude --worktree`
