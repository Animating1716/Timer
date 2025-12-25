FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Create data directory
RUN mkdir -p /data/habits

# Expose sync server port
EXPOSE 8080

# Default command runs sync server
CMD ["python", "sync_server.py"]
