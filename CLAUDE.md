# mojo-gpu-puzzles setup for macOS Silicon

## Environment setup

1. **Create virtual environment**: `uv venv`
2. **Install dependencies**: `uv pip install -e .` (uses pyproject.toml with modular-nightly index)
   - For Apple Silicon, no GPU extras needed (nvidia/amd optional dependencies not required)
3. **Activate venv**: `source .venv/bin/activate`
   - Or use `uv run` prefix for commands without activation

**Python version**: Requires Python >=3.10,<3.13 (compatible with .venv's Python 3.12.9)

## Running puzzles

- **Check GPU specs**: `uv run poe gpu-specs`
- **Run puzzle XX**: `uv run poe pXX` (e.g., `uv run poe p01`)
- **Test all solutions**: `uv run poe tests`
- **Test specific puzzle**: `uv run poe tests pXX`

## Notes for macOS Silicon

- Uses unified memory architecture
- Puzzles 1-8 and 11-15 are confirmed working on macOS
- No need for `-e apple` flag with uv (unlike pixi)
- Verify macOS 15.0+ and Xcode 16+ requirements

## Development

- Format code: `uv run poe format` (if configured)
- Available tasks: `uv run poe --help`

## Git protection

`.gitattributes` file protects `problems/` solutions from upstream merge conflicts using `merge=ours` strategy.

## Troubleshooting

### UV uses wrong Python version

If `uv run` tries to use Python 3.13.2 instead of the `.venv` (3.12.9):
- **Check environment variables**: `env | grep -i python` (look for `UV_PYTHON`, `PYTHON_VERSION`)
- **Use explicit path**: `uv run --python .venv/bin/python poe tests p01`
- **Or activate venv first**: `source .venv/bin/activate && poe tests p01`
- **`.python-version` file**: Created with `3.12.9` to hint UV


<terminal>

mojo-gpu-puzzles main !?📦 v1.0.0🐍 v3.12.9 via 🧚 on ☁️
fsh ❮ uv run -v poe tests p01
DEBUG uv 0.7.12 (dc3fd4647 2025-06-06)
DEBUG Found project root: `/Users/arthur/projects/mojo-gpu-puzzles`
DEBUG No workspace root found, using project root
DEBUG Discovered project `mojo-gpu-puzzles` at: /Users/arthur/projects/mojo-gpu-puzzles
DEBUG Acquired lock for `/Users/arthur/projects/mojo-gpu-puzzles`
DEBUG Using Python request `3.13.2` from explicit request
DEBUG Checking for Python environment at `.venv`
DEBUG The project environment's Python version does not satisfy the request: `Python 3.13.2`
DEBUG Searching for Python 3.13.2 in managed installations or search path
DEBUG Searching for managed installations at `/Users/arthur/.local/share/uv/python`
DEBUG Found managed installation `cpython-3.13.2-macos-aarch64-none`
DEBUG Found `cpython-3.13.2-macos-aarch64-none` at `/Users/arthur/.local/share/uv/python/cpython-3.13.2-macos-aarch64-none/bin/python3.13` (managed installations)
Using CPython 3.13.2
DEBUG Released lock at `/var/folders/87/p8v45fj16jsfngtm_kwdch9r0000gn/T/uv-db50ffb06eb55748.lock`
error: The requested interpreter resolved to Python 3.13.2, which is incompatible with the project's Python requirement: `>=3.10, <3.13`
</terminal>
