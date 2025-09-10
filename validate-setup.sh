#!/bin/bash

echo "UnoConvert Nginx Load Balancer Setup Validation"
echo "==============================================="

# Check if docker-compose.yml is valid
echo "1. Validating docker-compose configuration..."
if docker-compose config > /dev/null 2>&1; then
    echo "✓ docker-compose.yml is valid"
else
    echo "✗ docker-compose.yml has errors"
    exit 1
fi

# Check if nginx.conf syntax is valid (basic check)
echo "2. Checking nginx.conf syntax..."
if grep -q "upstream unoconvert_backend" nginx.conf && \
   grep -q "server unoconvert1:2004" nginx.conf && \
   grep -q "server unoconvert2:2004" nginx.conf && \
   grep -q "server unoconvert3:2004" nginx.conf; then
    echo "✓ nginx.conf contains required upstream configuration"
else
    echo "✗ nginx.conf is missing required upstream configuration"
    exit 1
fi

# Check if all required files exist
echo "3. Checking required files..."
required_files=("docker-compose.yml" "nginx.conf" "README.md" "demo/test-load-balancing.sh")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file is missing"
        exit 1
    fi
done

# Check if demo files exist
echo "4. Checking demo files..."
demo_files=("demo/demo.docx" "demo/demo.xlsx" "demo/test.sh")
for file in "${demo_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "⚠ $file is missing (optional for testing)"
    fi
done

echo ""
echo "Setup validation completed successfully!"
echo ""
echo "Next steps:"
echo "1. Start the services: docker-compose up -d"
echo "2. Test the setup: ./demo/test-load-balancing.sh"
echo "3. Check service status: docker-compose ps"
echo "4. View logs: docker-compose logs"
