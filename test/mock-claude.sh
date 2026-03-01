#!/bin/bash
# Mock Claude CLI for testing cl session manager
# Simulates Claude's behavior: runs interactively, responds to flags

echo "=== Mock Claude CLI ==="
echo "Args: $*"
echo ""

# Parse flags to show what cl passed
for arg in "$@"; do
    case "$arg" in
        --dangerously-skip-permissions) echo "[mock] Permission mode: skip" ;;
        --continue) echo "[mock] Mode: continue last conversation" ;;
        --resume) echo "[mock] Mode: resume picker" ;;
        --worktree) echo "[mock] Mode: worktree" ;;
        --permission-mode) echo "[mock] Permission mode: custom" ;;
    esac
done

echo ""
echo "[mock] Claude is running. Type 'exit' or press Ctrl+C to quit."
echo ""

# Simple interactive loop to simulate Claude
while true; do
    read -rp "claude> " input
    case "$input" in
        exit|quit|q)
            echo "[mock] Claude exiting."
            exit 0
            ;;
        "")
            ;;
        *)
            echo "[mock] You said: $input"
            ;;
    esac
done
