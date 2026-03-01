#!/bin/bash
# Build and run cl session manager test container
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Preparing test environment ==="

# Render Jinja2 template to plain bash (substitute variables)
sed 's/{% if cl_default_permission_mode | default('\''skip'\'') == '\''skip'\'' %}//' \
    "$PROJECT_DIR/templates/cl.sh.j2" | \
    sed '/{% else %}/,/{% endif %}/d' | \
    sed '/{% endif %}/d' \
    > "$SCRIPT_DIR/cl.sh"

# Copy tmux config (no Jinja2 vars in this one)
cp "$PROJECT_DIR/templates/tmux-cl.conf.j2" "$SCRIPT_DIR/tmux-cl.conf"

echo "=== Building Docker image ==="
docker build -t cl-test "$SCRIPT_DIR"

echo ""
echo "=== Starting test container ==="
echo ""
echo "You're in /src/test-project as 'dev' user."
echo ""
echo "Test commands:"
echo "  cl              # interactive menu"
echo "  cl -h           # help"
echo "  cl -n test      # new named session"
echo "  cl -l           # list sessions"
echo "  cl -w feature   # worktree session"
echo "  cl -c           # continue last conversation"
echo "  cl -r           # resume picker"
echo "  cl -x           # cleanup"
echo ""
echo "Inside tmux: Ctrl+B, D to detach, then 'cl' to see menu"
echo ""

exec docker run -it --rm --name cl-test cl-test
