# remoteclaud

Ansible playbook that sets up a complete Claude Code development environment on Rocky Linux ARM64 servers. One command, fully configured — Docker, Node.js, Go, Python, Claude CLI, and the `cl` session manager.

```bash
ansible-playbook -i inventory.ini playbook.yml
```

Then SSH in and start working:

```bash
ssh dev@your-server
cl    # interactive session manager
```

---

## What You Get

**Development tools**: Docker CE, Node.js (NVM), Go, Python 3, git, tmux, htop

**Claude Code**: CLI installed for both root and dev users, ready to use

**`cl` session manager**: Persistent Claude sessions in tmux with smart reattach, named sessions, worktrees, conversation resume, and cleanup

```
═══════════════════════════════════════════════════════
  cl - Session Manager                  /src/my-project
═══════════════════════════════════════════════════════

  SESSIONS

  [1]  my-project          attached      2h ago
  [2]  api-server          detached     35m ago
  [3]  feature-x    [wt]   detached      3h ago

  ─────────────────────────────────────────────────────

  [n]  New session        [w]  New worktree session
  [c]  New from last chat  [r]  Pick past conversation
  [x]  Clean up (1 orphaned)

═══════════════════════════════════════════════════════
  Select [1-3, n, w, c, r, x] or Enter for [2]:
```

## Requirements

| | |
|---|---|
| **Server** | Rocky Linux 9 (ARM64), root SSH access |
| **Local** | Ansible (`brew install ansible` or `pip install ansible`) |

## Quick Start

```bash
# 1. Clone and configure
git clone https://github.com/kojott/remoteclaud.git
cd remoteclaud
cp inventory.ini.example inventory.ini
# Edit inventory.ini with your server IP

# 2. Test connection
ansible -i inventory.ini claude_servers -m ping

# 3. Deploy
ansible-playbook -i inventory.ini playbook.yml

# 4. Start working
ssh dev@your-server
cl
```

## `cl` — Session Manager

All Claude sessions run in tmux, surviving SSH disconnects. Just `cl` to get back.

```bash
cl                      # Interactive menu (start here)
cl -a <name>            # Attach to session directly
cl -n <name>            # New named session
cl -w [name]            # New worktree session (requires git repo)
cl -c                   # Continue last conversation
cl -r                   # Pick past conversation to resume
cl -l                   # List sessions
cl -x                   # Clean up dead sessions & orphaned worktrees
cl -h                   # Help
```

**Smart defaults**: Press Enter to reattach to the most recent detached session — the most common action after SSH reconnect.

**Worktrees**: `cl -w feature` delegates to `claude --worktree` for isolated git branches.

**Cleanup**: Two-phase — lists candidates first, never auto-deletes worktrees with uncommitted changes.

## Selective Deployment

Every task is tagged. Deploy only what you need:

```bash
ansible-playbook -i inventory.ini playbook.yml --tags docker
ansible-playbook -i inventory.ini playbook.yml --tags claude,cl
ansible-playbook -i inventory.ini playbook.yml --tags motd,templates
```

| Tag | What it does |
|-----|-------------|
| `system` | OS update, EPEL repo |
| `tools` | git, tmux, htop, curl, wget, Development Tools |
| `docker` | Docker CE + Compose |
| `node` | NVM + Node.js LTS |
| `python` | Python 3 + pip |
| `go` | Go (ARM64) |
| `claude` | Claude CLI |
| `cl` | `cl` session manager + tmux config |
| `dirs` | `/src` directory |
| `templates` | Server README, new-project script, docker-compose template |
| `motd` | Login message |
| `config` | `.bashrc` PATH setup |
| `git` | Git user config |
| `user` | All dev-user tasks |
| `verify` | Version checks |

## Adding Servers

```ini
# inventory.ini
[claude_servers]
server-1 ansible_host=1.2.3.4 ansible_user=root
server-2 ansible_host=5.6.7.8 ansible_user=root

[claude_servers:vars]
git_user_name=Your Name
git_user_email=your@email.com
```

## Configuration

Variables at the top of `playbook.yml`:

```yaml
vars:
  nvm_version: "0.40.1"
  go_version: "1.23.4"
  dev_user: "dev"
  src_dir: "/src"
  cl_default_permission_mode: "skip"   # "skip" or "acceptEdits"
  git_user_name: "Claude Dev"
  git_user_email: "dev@localhost"
```

## VS Code Remote SSH

```
# ~/.ssh/config
Host my-claude-server
    HostName 1.2.3.4
    User dev
    IdentityFile ~/.ssh/id_rsa
```

Then: `Cmd+Shift+P` → "Remote-SSH: Connect to Host" → Open `/src/<project>`

## Project Structure

```
remoteclaud/
├── playbook.yml                         # Ansible playbook (all tasks)
├── inventory.ini.example                # Server list template
├── test/                                # Docker-based test environment
│   ├── Dockerfile
│   ├── mock-claude.sh
│   └── run-test.sh
└── templates/
    ├── cl.sh.j2                         # cl session manager
    ├── tmux-cl.conf.j2                  # tmux config for cl
    ├── motd.sh.j2                       # Login MOTD
    ├── README.txt.j2                    # ~/README.txt on server
    ├── new-project.sh.j2               # New project script
    └── docker-compose.template.yml.j2  # Docker template
```

## Testing

```bash
# Docker-based functional test of cl session manager
./test/run-test.sh

# Ansible dry run against real server
ansible-playbook -i inventory.ini playbook.yml --check --diff
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| SSH key not accepted | `ssh-copy-id root@server-ip` |
| Ansible can't reach server | `ansible -i inventory.ini claude_servers -m ping -vvv` |
| Docker not running | `systemctl status docker && journalctl -u docker` |
| `cl` not found | `source ~/.bashrc` or run `~/bin/cl` directly |

---

### Need a Server?

I use [Hetzner Cloud](https://hetzner.cloud/?ref=eWgHw8GraDd5) for all my Claude dev servers — ARM64 support, great performance, unbeatable prices. [Get **€20 free credits**](https://hetzner.cloud/?ref=eWgHw8GraDd5) to try this setup.

## License

[MIT](LICENSE)
