# Claude Dev Environment - Ansible Automation

Ansible playbook for automated installation of Claude development environment on Rocky Linux ARM64 servers.

---

## ☁️ Need a Server? I Recommend Hetzner Cloud

I personally use [**Hetzner Cloud**](https://hetzner.cloud/?ref=eWgHw8GraDd5) for all my Claude dev servers - great performance, unbeatable prices, and ARM64 support.

**👉 [Get €20 FREE credits with this link](https://hetzner.cloud/?ref=eWgHw8GraDd5)** - enough to test this setup for weeks!

---

**IMPORTANT:** For working with Claude CLI, login as user `dev` (not root):
```bash
ssh dev@<server-ip>
```

## What Gets Installed

- EPEL repository
- Basic tools (git, tmux, htop, curl, wget)
- Development Tools (gcc, make, ...)
- Docker CE + Docker Compose plugin
- NVM + Node.js LTS
- Python 3 + pip
- Go (ARM64)
- Claude CLI (@anthropic-ai/claude-code)
- Claunch + `cl` command (interactive session manager)

## What Gets Configured

- `/src` directory for projects
- `~/README.txt` - quick reference for working on server
- MOTD - shows running Claude sessions on login
- PATH in `.bashrc` for Go, NVM, ~/bin

## Requirements

### Local Machine
```bash
# macOS
brew install ansible

# or pip
pip install ansible
```

### Server
- Rocky Linux 9 (ARM64)
- SSH access as root
- Internet connection

## How to Run

### 1. Verify Connection
```bash
ansible -i inventory.ini claude_servers -m ping
```

### 2. Dry Run (test without changes)
```bash
ansible-playbook -i inventory.ini playbook.yml --check
```

### 3. Installation
```bash
ansible-playbook -i inventory.ini playbook.yml
```

### 4. Specific Tags Only
```bash
# Docker only
ansible-playbook -i inventory.ini playbook.yml --tags docker

# Claude tools only
ansible-playbook -i inventory.ini playbook.yml --tags claude,claunch

# MOTD and README only
ansible-playbook -i inventory.ini playbook.yml --tags motd,templates
```

## Adding a New Server

1. Copy the example inventory (if not done already):
```bash
cp inventory.ini.example inventory.ini
```

2. Edit `inventory.ini`:
```ini
[claude_servers]
my-server ansible_host=1.2.3.4 ansible_user=root
another-server ansible_host=5.6.7.8 ansible_user=root

[claude_servers:vars]
git_user_name=Your Name
git_user_email=your@email.com
```

3. Run the playbook:
```bash
ansible-playbook -i inventory.ini playbook.yml
```

## VS Code Remote SSH

### Configuration (~/.ssh/config)
```
Host my-claude-server
    HostName 1.2.3.4
    User dev
    IdentityFile ~/.ssh/id_rsa
```

### Workflow
1. VS Code: `Cmd+Shift+P` → "Remote-SSH: Connect to Host"
2. Select `my-claude-server`
3. Open `/src/<project>`

## Working on the Server

After login, MOTD displays overview of running Claude sessions.

### Quick Start - Just Type `cl`

The easiest way to work with Claude on the server is the **`cl`** command - an interactive session manager:

```bash
cl                      # Interactive menu - select existing session or create new one
```

This gives you a menu to:
- See all running tmux sessions
- Attach to any existing session with one keypress
- Start a new Claude session in current directory

### New Project
```bash
cd /src
mkdir my-project && cd my-project
git init
cl                      # Interactive menu to start Claude
```

### Direct Claunch Commands
```bash
claunch                 # Start Claude in current directory
claunch --tmux          # Start in tmux (persistent session)
claunch list            # List running sessions
claunch clean           # Clean orphaned sessions
```

### Working with tmux Sessions
```bash
cl                      # Easiest way - interactive menu
# or manually:
claunch --tmux          # Start Claude in tmux
# Ctrl+B, D             # Detach
tmux attach -t <name>   # Reattach
```

### Useful Commands
```bash
cl                      # Interactive session manager
src                     # Alias for "cd /src"
cat ~/README.txt        # Quick reference
```

## Project Structure

```
remoteclaude/
├── README.md                            # This file
├── CLAUDE.md                            # Context for Claude
├── inventory.ini.example               # Server list template (copy to inventory.ini)
├── inventory.ini                        # Your local server list (git ignored)
├── playbook.yml                         # Main Ansible playbook
├── server-readme.txt                    # Copy of README for server
└── templates/
    ├── new-project.sh.j2                # New project script
    ├── docker-compose.template.yml.j2   # Docker template
    ├── README.txt.j2                    # README for ~/README.txt
    ├── motd.sh.j2                       # MOTD script
    └── cl.sh.j2                         # Interactive session manager
```

## Troubleshooting

### SSH Key Not Accepted
```bash
ssh-copy-id root@<server-ip>
```

### Ansible Can't See Server
```bash
ansible -i inventory.ini claude_servers -m ping -vvv
```

### Docker Not Working
```bash
systemctl status docker
journalctl -u docker
```

### Claunch Not in PATH
```bash
source ~/.bashrc
# or
~/bin/claunch --help
```
