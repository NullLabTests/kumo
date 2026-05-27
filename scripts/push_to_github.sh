#!/usr/bin/env bash
set -euo pipefail

echo "=== KumoRFM Demo Studio - GitHub Push Script ==="

# Configuration - change these!
REPO_NAME="kumorfm-demo-studio"
GITHUB_USER=""
DESCRIPTION="Full-stack demo application showcasing KumoRFM (Kumo Relational Foundation Model) capabilities including demand forecasting, churn prediction, product recommendations, entity attribute inference, and model explainability."

if [ -z "${GITHUB_USER}" ]; then
  echo "Please edit this script and set GITHUB_USER to your GitHub username."
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# Create .gitignore
cat > .gitignore << 'GITIGNORE'
__pycache__/
*.py[cod]
*$py.class
*.so
.env
.venv/
venv/
*.egg-info/
dist/
build/
.DS_Store
node_modules/
*.parquet
*.csv
*.ipynb
GITIGNORE

# Create LICENSE (MIT)
cat > LICENSE << 'LICENSE'
MIT License

Copyright (c) 2024 KumoRFM Demo Studio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE

# Create README
cat > README.md << 'README'
# KumoRFM Demo Studio

> **A full-stack interactive demo showcasing [KumoRFM](https://kumo.ai) — the Relational Foundation Model for business data.**

![License](https://img.shields.io/badge/license-MIT-blue)
![Python](https://img.shields.io/badge/python-3.9%2B-blue)
![FastAPI](https://img.shields.io/badge/built%20with-FastAPI-green)

## Overview

KumoRFM is a foundation model that generates accurate predictions from relational business data **without any model training or feature engineering**. Feed it your tables (as DataFrames), prompt it with a SQL-like query, and get predictions in about a second.

This demo application provides a visual, interactive interface to explore KumoRFM's capabilities across multiple use cases.

## Features

### 8 Interactive Demo Modules

| Module | Description |
|--------|-------------|
| **Data Explorer** | Load and inspect relational datasets (tables, schemas, links) |
| **Query Lab** | Write PQL queries interactively with 8 built-in templates |
| **Demand Forecasting** | Predict future product sales using time-window aggregations |
| **Customer Churn** | Identify users at risk of churn |
| **Product Recommendations** | Top-N item suggestions for specific users |
| **Model Explainability** | Get natural-language explanations for predictions |
| **Entity Attribute Inference** | Predict missing entity attributes (e.g., user age) |
| **Batch Prediction** | Run predictions across multiple entities |

### Pre-loaded Datasets

- **Online Shopping (E-Commerce)** — users, items, orders
- **E-Commerce with Returns (H&M)** — users, items, orders, returns
- **Steam Gaming Platform** — users, games, reviews

### Supported PQL Tasks

| Task | Example PQL |
|------|-------------|
| Regression | `PREDICT SUM(orders.price, 0, 30, days) FOR items.item_id=42` |
| Binary Classification | `PREDICT COUNT(orders.*, 0, 90, days)=0 FOR users.user_id IN (42, 123)` |
| Ranking / Recommendation | `PREDICT LIST_DISTINCT(orders.item_id, 0, 30, days) RANK TOP 10 FOR users.user_id=123` |
| Attribute Inference | `PREDICT users.age FOR users.user_id=8` |
| Filtered Aggregation | `PREDICT COUNT(reviews.* WHERE reviews.is_recommended=1, 0, 30, days) FOR games.app_id=263460` |

## Architecture

```
kumorfm-demo-studio/
├── backend/
│   ├── main.py          # FastAPI server wrapping kumoai SDK
│   ├── config.py        # Configuration (API key, host, port)
│   ├── requirements.txt # Python dependencies
│   └── __init__.py
├── frontend/
│   └── dist/
│       └── index.html   # Single-page application (no build step!)
├── scripts/
│   └── push_to_github.sh # Script to deploy to GitHub
├── .env                 # Your KumoRFM API key
├── .gitignore
├── LICENSE              # MIT License
└── README.md
```

## Getting Started

### Prerequisites

- Python 3.9+
- A [KumoRFM API key](https://kumorfm.ai) (free tier available)

### Installation

```bash
# 1. Clone or download this repository
git clone https://github.com/<your-username>/kumorfm-demo-studio.git
cd kumorfm-demo-studio

# 2. Install Python dependencies
pip install -r backend/requirements.txt

# 3. Set your API key
echo "KUMO_API_KEY=your_api_key_here" > .env
```

### Running the Application

```bash
python backend/main.py
```

Open your browser to **http://localhost:8080**

The frontend is served as a static SPA from the FastAPI server — no additional build steps required.

### Using with Docker (Optional)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "backend/main.py"]
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check and API key status |
| POST | `/api/init` | Initialize KumoRFM with API key |
| POST | `/api/load-dataset` | Load a pre-built dataset |
| GET | `/api/graph/{id}` | Get graph schema info |
| POST | `/api/predict` | Run a single PQL prediction |
| POST | `/api/predict/batch` | Run batch predictions |
| POST | `/api/evaluate` | Evaluate a query against historical data |
| GET | `/api/pql-templates` | Get PQL template suggestions |
| GET | `/api/datasets` | List available pre-built datasets |

## PQL Quick Reference

```sql
PREDICT <target_expression>
FOR   <entity_specification>
```

### Aggregation Functions

| Function | Description |
|----------|-------------|
| `SUM(col, start, end, unit)` | Sum of numeric values in window |
| `AVG(col, start, end, unit)` | Average of numeric values |
| `COUNT(table.*, start, end, unit)` | Count of rows |
| `COUNT_DISTINCT(col, start, end, unit)` | Count of unique values |
| `LIST_DISTINCT(col, start, end, unit)` | List of unique values (use with `RANK TOP K`) |
| `MIN/MAX(col, start, end, unit)` | Min/Max numeric value |

**Time window offsets:** `0` = now, positive = future, negative = past. Unit: `days`, `hours`, `months`.

### Configurable Options

- `run_mode`: `"fast"` (1K examples), `"normal"` (5K), `"best"` (10K)
- `anchor_time`: Timestamp to predict "as of" (past for evaluation, future for forecasting)
- `num_neighbors`: Control subgraph sampling per hop
- `max_pq_iterations`: Max iterations for collecting in-context examples

## The KumoRFM Model

KumoRFM is built on two core innovations:

1. **Pre-trained Graph Transformer**: An encoder that learns representations across multiple tables, eliminating custom ML pipelines.
2. **In-context Learning**: At inference time, it retrieves labeled subgraph examples as context to inform predictions, eliminating task-specific model training.

## License

MIT License — see [LICENSE](LICENSE)

## Resources

- [KumoRFM Website](https://kumorfm.ai)
- [GitHub Repository](https://github.com/kumo-ai/kumo-rfm)
- [Research Paper](https://kumo.ai/research/kumo_relational_foundation_model.pdf)
- [KumoRFM-2 Paper](https://kumo.ai/kumoRFM-2-scaling-foundation-models-for-relational-learning.pdf)
- [MCP Server](https://github.com/kumo-ai/kumo-rfm-mcp)
- [Discord Community](https://discord.gg/uNB4bJkapQ)
README

# Initialize git repo
git init
git add -A
git commit -m "Initial commit: KumoRFM Demo Studio

Full-stack demo application showcasing KumoRFM capabilities:
- Interactive PQL Query Lab with 8 template queries
- Demand forecasting with time-window aggregations
- Customer churn prediction (binary classification)
- Product recommendations (ranking TOP-N)
- Model explainability with natural language summaries
- Entity attribute inference (missing value imputation)
- Data explorer with schema visualization
- Pre-loaded datasets for e-commerce and gaming

Architecture:
- Backend: Python FastAPI server wrapping kumoai SDK
- Frontend: Single-page HTML/JS application (no build step)
- All predictions via KumoRFM foundation model (no training)

Tech stack: Python, FastAPI, kumoai SDK, pandas, scikit-learn"

# Create GitHub repository and push
echo ""
echo "=== Creating GitHub repository ==="
gh repo create "${GITHUB_USER}/${REPO_NAME}" --public --description "${DESCRIPTION}" --source=. --remote=origin --push

echo ""
echo "=== Done! ==="
echo "Repository: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo ""
echo "Next steps:"
echo "  1. Set up your KumoRFM API key: echo \"KUMO_API_KEY=your_key\" > .env"
echo "  2. Run the app: python backend/main.py"
echo "  3. Open http://localhost:8080"
