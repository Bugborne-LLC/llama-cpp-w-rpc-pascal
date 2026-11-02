#!/bin/sh
set -e

# 1. Configure Git identity (allows override via env vars)
git config --global user.name "${GIT_USER_NAME:-pi-agent}"
git config --global user.email "${GIT_USER_EMAIL:-pi-agent@local.invalid}"
git config --global init.defaultBranch main

# Automatically set upstream tracking on 'git push' for new branches
git config --global push.autoSetupRemote true

# Clean up host variable (strip trailing slashes)
FORGEJO_HOST="${FORGEJO_HOST:-http://forgejo:3000}"
FORGEJO_HOST="${FORGEJO_HOST%/}"

# 2. Authenticate Forgejo & Git
if [ -n "$FORGEJO_TOKEN" ] && [ -n "$FORGEJO_USER" ]; then
    echo "Configuring fj CLI and Git credentials for $FORGEJO_USER..."
    
    fj --host "$FORGEJO_HOST" auth add-key "$FORGEJO_USER" "$FORGEJO_TOKEN" || true
    
    git config --global credential.helper store
    printf "url=%s\nusername=%s\npassword=%s\n\n" "$FORGEJO_HOST" "$FORGEJO_USER" "$FORGEJO_TOKEN" | git credential approve
    
    unset FORGEJO_TOKEN
fi

# 3. Dynamic Repository Cloning & Branch Management
if [ -n "$REPO_URL" ]; then
    REPO_NAME=$(basename "$REPO_URL" .git)
    TARGET_DIR="/workspace/$REPO_NAME"

    if [ ! -d "$TARGET_DIR/.git" ]; then
        echo "Cloning target repo from $REPO_URL..."
        git clone "$REPO_URL" "$TARGET_DIR"
    else
        echo "Repo already exists at $TARGET_DIR. Fetching latest..."
        git -C "$TARGET_DIR" fetch --all
    fi

    cd "$TARGET_DIR"

    # Branch setup logic
    if [ -n "$TARGET_BRANCH" ]; then
        echo "Setting up workspace branch: $TARGET_BRANCH"
        
        # 1. Check if the branch exists locally or on remote origin
        if git show-ref --verify --quiet "refs/heads/$TARGET_BRANCH" || \
           git show-ref --verify --quiet "refs/remotes/origin/$TARGET_BRANCH"; then
            
            echo "Checking out existing branch '$TARGET_BRANCH'..."
            git checkout "$TARGET_BRANCH"
            git pull origin "$TARGET_BRANCH" --ff-only || true
        else
            echo "Branch '$TARGET_BRANCH' not found. Creating new feature branch from default branch..."
            git checkout -b "$TARGET_BRANCH"
        fi
    fi
fi

# 4. Light Android Initialization (no network updates)
if command -v android >/dev/null 2>&1; then
    android init || true
fi

# 5. Hand off execution
if [ "$1" = "/bin/bash" ]; then
    shift
    set -- /bin/bash "$@"
fi

if [ $# -eq 0 ]; then
    exec /bin/bash
else
    exec "$@"
fi
