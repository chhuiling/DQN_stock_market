# DQN Stock Market Trading Agent

A Deep Q-Network (DQN) agent trained to learn optimal buy/sell/hold policies from historical stock price data. The full pipeline — environment setup, dependency installation, training, and evaluation — is automated via a single Bash script.

---

## Overview

This project implements a custom reinforcement learning environment that simulates real market mechanics: portfolio tracking, position management, and transaction costs. The agent learns purely from price history and technical indicators, with no hand-crafted rules.

**Key design decisions:**

- **AdamW optimizer + Huber Loss** — stable weight decay and robustness against the extreme outliers common in financial time series
- **Reward shaping** — combines Sharpe Ratio maximization with inactivity penalties to prevent the classic "lazy agent" problem (holding cash forever)
- **Early stopping** — monitors validation Sharpe Ratio across episodes with configurable patience to avoid overfitting to training data
- **Decoupled pipeline** — setup and execution are separate steps; the environment is fully isolated and does not touch system-level Python

---

## Project Structure

```
DQN_stock_market/
├── notebooks/
│   ├── stock_market.ipynb            # Source notebook
│   └── stock_market_executed.ipynb   # Output with logs and charts (generated)
├── data/
│   └── NVDA.csv                      # Historical price dataset
├── requirements.txt                  # Python dependencies
└── setup.sh                          # Environment builder
```

---

## Requirements

- Python **3.11** (required — TensorFlow does not support 3.12+)
- `curl` (for pyenv installation if Python 3.11 is not available)
- Linux or macOS

> The setup script will automatically install **pyenv** and Python 3.11 if they are not already present on your system. No manual steps needed.

---

## Quickstart

### 1. Clone the repository

```bash
git clone https://github.com/chhuiling/DQN_stock_market.git
cd DQN_stock_market
```

### 2. Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Install pyenv and Python 3.11 if missing
- Create an isolated virtual environment (`rl_env/`)
- Install all dependencies from `requirements.txt`
- Register a Jupyter kernel for the environment
- Verify that all critical modules loaded correctly

### 3. Run the notebook

```bash
JUPYTER_PATH="$HOME/.local/share/jupyter" ./rl_env/bin/python -m nbconvert --to 'notebook' --execute notebooks/stock_market.ipynb --ExecutePreprocessor.kernel_name=rl_env --ExecutePreprocessor.timeout=-1 --output stock_market_executed.ipynb
```

The executed notebook with all outputs and charts will be saved as `stock_market_executed.ipynb`.

> **Note:** Training time varies by hardware but can take up to 2 hours on CPU. The process is not frozen — it is running. To reduce runtime, lower the episode count, reduce the dataset size, or increase the early stopping patience threshold directly in the notebook.

---

## Output

During training, the agent saves model checkpoints as `.keras` files:

- `ai_trader_{episode}.keras` — saved whenever a new best validation Sharpe is achieved
- `ai_trader_{N}.keras` — periodic checkpoint every 10 episodes

The final executed notebook contains per-episode metrics (profit, win rate, Sharpe ratio, average loss) and visualizations for both training and validation sets.

---

## Configuration

Key parameters are defined at the top of the notebook:

| Parameter | Description |
|---|---|
| `episodes` | Number of training episodes |
| `batch_size` | Replay buffer batch size |
| `patience` | Early stopping patience (episodes without improvement) |
| `state_size` | Number of input features to the DQN |

---

## Dependencies

Core libraries: `tensorflow`, `pandas`, `numpy`, `matplotlib`, `mplfinance`, `seaborn`, `TA-Lib`, `tqdm`

All versions are pinned in `requirements.txt`.
