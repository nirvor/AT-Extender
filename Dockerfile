# Use Python 3.11 slim image for smaller size
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies required for Playwright
# This list is from your file and is correct
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright browsers WITHOUT system dependencies, as they are manually installed above
RUN playwright install

# Copy application code
COPY . .

# Create directories for data persistence (as used in at-extender.py)
RUN mkdir -p /app/data

# Set proper permissions (excellent practice from your file)
RUN useradd -m -u 1000 atextender && \
    chown -R atextender:atextender /app
USER atextender

# Health check (this is valid because healthcheck.py exists in your repo)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python healthcheck.py || exit 1

# Expose port (if needed for future web interface)
EXPOSE 8080

# Set the correct entrypoint to run your script
CMD ["python", "at-extender.py"]
