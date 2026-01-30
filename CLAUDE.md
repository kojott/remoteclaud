# Claude Dev Environment Automation

## What This Project Does

Ansible playbook for automated installation of a development environment for working with Claude CLI on remote Rocky Linux ARM64 servers.

**IMPORTANT:** Claude CLI cannot run as root. Use the `dev` user for development:
```bash
ssh dev@<server-ip>
```

## Project Structure

```
remoteclaude/
├── inventory.ini.example  # Server list template
├── inventory.ini          # Your local server list (git ignored)
├── playbook.yml           # Main Ansible playbook
├── server-readme.txt      # Local copy of server README
└── templates/
    ├── new-project.sh.j2           # New project script
    ├── docker-compose.template.yml.j2  # Docker template
    ├── README.txt.j2               # README for ~/README.txt
    ├── motd.sh.j2                  # MOTD on login
    └── cl.sh.j2                    # Interactive session manager ("cl" command)
```

## Key Server Components

### Directory Structure
- `/src` - Main directory for projects
- `/src/templates` - Templates for new projects
- `~/README.txt` - Quick reference
- `~/bin/claunch` - Claunch binary
- `~/bin/cl` - Interactive session manager

### Users
- **root** - Ansible deployment, system administration
- **dev** - Development, Claude CLI, docker (member of docker group)

### Installed Tools
- **Docker CE** - Containers
- **Node.js** (via NVM) - JavaScript runtime (root and dev)
- **Go** - For Go projects
- **Python 3** - Python runtime
- **Claude CLI** - `@anthropic-ai/claude-code` (root and dev)
- **Claunch** - Session manager (root and dev) - https://github.com/0xkaz/claunch

### PATH Configuration
Added to `.bashrc`:
- `/usr/local/go/bin` - Go binaries
- `~/go/bin` - Go projects
- `~/bin` - Claunch and local binaries
- NVM setup

### MOTD
On login displays:
- Quick start commands
- List of running Claude/tmux sessions

## Playbook Tags

| Tag | Description |
|-----|-------------|
| `system` | System update, EPEL |
| `tools` | Basic tools (git, tmux, htop...) |
| `docker` | Docker CE + Compose |
| `node` | NVM + Node.js |
| `python` | Python 3 + pip |
| `go` | Go lang |
| `claude` | Claude CLI |
| `claunch` | Claunch session manager |
| `dirs` | Directories (/src) |
| `templates` | Templates + ~/README.txt |
| `motd` | MOTD script |
| `config` | .bashrc configuration |
| `git` | Git user configuration |
| `user` | Dev user setup (NVM, Node, Claude, Claunch) |
| `verify` | Installation verification |

## How to Add a New Server

1. Copy the example inventory (if not done already):
```bash
cp inventory.ini.example inventory.ini
```

2. Add to `inventory.ini`:
```ini
new-server ansible_host=IP_ADDRESS ansible_user=root
```

3. Run: `ansible-playbook -i inventory.ini playbook.yml`

## How to Add New Software

1. Add task to `playbook.yml` in appropriate section
2. Add tag for selective installation
3. Update README.md and this file

## Playbook Variables

```yaml
vars:
  nvm_version: "0.40.1"
  go_version: "1.23.4"
  node_version: "lts/*"
  src_dir: "/src"
  dev_user: "dev"
  git_user_name: "Claude Dev"      # Customize for your setup
  git_user_email: "dev@localhost"  # Customize for your setup
```

## Common Modifications

### Change Go Version
In `playbook.yml` change `go_version` variable.

### Change Node.js Version
In `playbook.yml` change `nvm_version` or modify `nvm install` command.

### Modify MOTD
Edit `templates/motd.sh.j2` and run:
```bash
ansible-playbook -i inventory.ini playbook.yml --tags motd
```

### Modify Server README
Edit `templates/README.txt.j2` and run:
```bash
ansible-playbook -i inventory.ini playbook.yml --tags templates
```

### Customize Git User
Override in `inventory.ini` per host or group:
```ini
[claude_servers:vars]
git_user_name=Your Name
git_user_email=your@email.com
```

## Dependencies

- **Claunch**: https://github.com/0xkaz/claunch (installed to ~/bin)
- **Claude CLI**: npm package @anthropic-ai/claude-code
- **EPEL**: Required for htop on Rocky Linux
