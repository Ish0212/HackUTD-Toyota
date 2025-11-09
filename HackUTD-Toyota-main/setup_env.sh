#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/toyota-vehicle-finder/backend"
FRONTEND_DIR="$ROOT_DIR/toyota-vehicle-finder/frontend"

echo "🚗 Setting up Toyota Vehicle Finder environment..."

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required but was not found on the PATH." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required but was not found on the PATH." >&2
  exit 1
fi

# Create Python virtual environment if it does not exist
USE_VENV=true
if [ ! -d "$BACKEND_DIR/.venv" ]; then
  echo "Creating Python virtual environment in $BACKEND_DIR/.venv"
  if python3 -m venv "$BACKEND_DIR/.venv"; then
    :
  else
    echo "⚠️  Could not create virtual environment. Falling back to user-level pip installation."
    USE_VENV=false
  fi
fi

echo "Installing backend dependencies..."
if [ "$USE_VENV" = true ] && [ -f "$BACKEND_DIR/.venv/bin/activate" ]; then
  # shellcheck disable=SC1091
  source "$BACKEND_DIR/.venv/bin/activate"
  pip install --upgrade pip
  pip install -r "$BACKEND_DIR/requirements.txt"
  deactivate
else
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user -r "$BACKEND_DIR/requirements.txt"
fi

echo "Installing frontend dependencies..."
(
  cd "$FRONTEND_DIR"
  npm install
)

echo "Writing backend environment file..."
cat <<'EOF' > "$BACKEND_DIR/.env"
GEMINI_API_KEY=your_api_key_here
EOF

echo "Writing frontend environment file..."
cat <<'EOF' > "$FRONTEND_DIR/.env.local"
NEXT_PUBLIC_API_URL=http://localhost:8000
EOF

echo "✅ Environment setup complete."
