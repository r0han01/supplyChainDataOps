#!/bin/bash

set -e

echo "🚀 Cloud-Native Supply Chain Analytics - Setup"
echo "=============================================="
echo ""

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "   Install: https://www.python.org/downloads/"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "✓ Python 3 found: $PYTHON_VERSION"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install -q --upgrade pip

# Install dependencies
echo "📦 Installing dependencies from requirements.txt..."
if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt not found"
    exit 1
fi

pip install -q -r requirements.txt
echo "✅ Dependencies installed"
echo ""

# Create necessary directories
echo "📁 Creating project directories..."
mkdir -p localData
echo "✅ Created localData directory for dataset downloads"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo "⚠️  .env file not found."
        echo "   Copy .env.example to .env and configure your credentials:"
        echo "   cp .env.example .env"
        echo ""
        echo "   Required environment variables:"
        echo "   - KAGGLE_API_TOKEN (from https://www.kaggle.com/settings/account)"
        echo "   - AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY (from AWS IAM)"
        echo "   - S3_BUCKET_NAME (your S3 bucket name)"
        echo "   - SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD"
        echo ""
    else
        echo "⚠️  .env.example not found. Please create .env manually."
    fi
else
    echo "✓ .env file exists"
fi

# Optional: Check for Terraform
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform --version | head -n1 | cut -d' ' -f2)
    echo "✓ Terraform found: $TERRAFORM_VERSION"
else
    echo "⚠️  Terraform not found (optional for now, required for step 5)"
    echo "   Install: https://www.terraform.io/downloads"
fi

# Optional: Check for dbt
if command -v dbt &> /dev/null; then
    DBT_VERSION=$(dbt --version | head -n1 | cut -d' ' -f2)
    echo "✓ dbt found: $DBT_VERSION"
else
    echo "⚠️  dbt not found (optional for now, required for step 7)"
    echo "   Install: pip install dbt-snowflake"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Configure .env file with your credentials (if not done)"
echo "  2. Run: python dataFetcher/dataFetcher.py (to fetch data from Kaggle)"
echo "  3. Follow the remaining steps in README.md"
echo ""
