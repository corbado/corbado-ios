#!/bin/bash

# Script to generate Swift HTTP client from OpenAPI specs
# This replaces the manual 3-step process

set -e  # Exit on any error

echo "🔄 Generating Swift HTTP client from OpenAPI specs..."

# Step 1: Generate the client
echo "📝 Running openapi-generator..."
openapi-generator generate -i openapi/corbado_public_api.yml -g swift6 -o Sources/CorbadoAPIClient

# Step 2: Remove the previous client
echo "🗑️  Removing previous client..."
rm -rf Sources/OpenAPIClient

# Step 3: Move the new client to the correct location
echo "📦 Moving new client to Sources..."
mv Sources/CorbadoAPIClient/Sources/OpenAPIClient Sources/

# Clean up the temporary directory
echo "🧹 Cleaning up temporary files..."
rm -rf Sources/CorbadoAPIClient

echo "✅ Client generation complete!" 