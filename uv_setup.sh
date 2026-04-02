#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# AgiBotWorld Challenge ICRA 2026 — World Model Baseline
# Environment setup script using uv
# Run from the root of the repository.
# =============================================================================

# ---------------------------------------------------------------------------- #
# 1. Check that uv is installed
# ---------------------------------------------------------------------------- #
if ! command -v uv &>/dev/null; then
    echo "Error: 'uv' is not installed or not in PATH."
    echo "Install it with:  curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

echo ">>> uv found: $(uv --version)"

# ---------------------------------------------------------------------------- #
# 2. Install Python 3.10.4 and create the virtual environment
# ---------------------------------------------------------------------------- #
echo ">>> Installing Python 3.10.4..."
uv python install 3.10.4

echo ">>> Creating virtual environment .venv..."
uv venv .venv --python 3.10.4

echo ">>> Activating virtual environment..."
# shellcheck disable=SC1091
source .venv/bin/activate

# ---------------------------------------------------------------------------- #
# 3. Upgrade setuptools (fixes mmcv build isolation issue)
# ---------------------------------------------------------------------------- #
echo ">>> Upgrading setuptools..."
uv pip install --upgrade setuptools

# ---------------------------------------------------------------------------- #
# 4. Install mmcv from the OpenMMLab prebuilt wheel (cu121 + torch2.4)
#    Building from source fails due to pkg_resources not being available
#    inside pip's isolated build environment.
# ---------------------------------------------------------------------------- #
echo ">>> Installing mmcv==2.2.0 from OpenMMLab prebuilt wheel..."
uv pip install mmcv==2.2.0 \
    -f https://download.openmmlab.com/mmcv/dist/cu121/torch2.4/index.html

# ---------------------------------------------------------------------------- #
# 5. Install remaining dependencies from requirements.txt (mmcv excluded)
# ---------------------------------------------------------------------------- #
echo ">>> Installing requirements.txt (mmcv excluded)..."
grep -v '^mmcv' requirements.txt | uv pip install -r /dev/stdin

# ---------------------------------------------------------------------------- #
# 6. Install iopath, then pytorch3d from the prebuilt wheel
#    iopath must be installed first as it is a dependency of pytorch3d
#    and is not available in the prebuilt wheel index.
# ---------------------------------------------------------------------------- #
echo ">>> Installing iopath..."
uv pip install iopath

echo ">>> Installing pytorch3d from prebuilt wheel (py310 + cu121 + pyt240)..."
uv pip install pytorch3d \
    -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py310_cu121_pyt240/download.html

# ---------------------------------------------------------------------------- #
# 7. Update the evac git submodule
# ---------------------------------------------------------------------------- #
echo ">>> Updating evac submodule..."
git submodule update --init --remote

# ---------------------------------------------------------------------------- #
echo ""
echo "==> Setup complete. To activate the environment in future sessions:"
echo "    source .venv/bin/activate"
