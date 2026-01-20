#!/bin/bash
# Validation script for cross-compiled nimjl binaries
# Usage: ./validate_cross_compile.sh <binary_path>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <binary_path>"
    echo "Example: $0 ./myapp"
    exit 1
fi

BINARY="$1"

if [ ! -f "$BINARY" ]; then
    echo "Error: Binary '$BINARY' not found"
    exit 1
fi

echo "=== Validating Cross-Compiled Binary: $BINARY ==="
echo ""

# 1. Check architecture
echo "1. Architecture Check:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    lipo -info "$BINARY" || file "$BINARY"
else
    file "$BINARY"
fi
echo ""

# 2. Check Julia library dependencies
echo "2. Julia Library Dependencies:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    otool -L "$BINARY" | grep -i julia || echo "  No Julia libraries found (may be statically linked)"
else
    ldd "$BINARY" 2>/dev/null | grep -i julia || echo "  No Julia libraries found (may be statically linked)"
fi
echo ""

# 3. Check embedded Julia version
echo "3. Embedded Julia Version:"
strings "$BINARY" | grep "Nimjl> Using" | head -1 || echo "  Version string not found"
echo ""

# 4. Check for cross-compilation flag
echo "4. Cross-Compilation Mode:"
if strings "$BINARY" | grep -q "Cross-compilation mode enabled"; then
    echo "  ✓ Binary was compiled with -d:nimjl_cross_compile"
else
    echo "  ✗ Binary was compiled in normal mode"
fi
echo ""

# 5. Size check
echo "5. Binary Size:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    ls -lh "$BINARY" | awk '{print "  " $5}'
else
    ls -lh "$BINARY" | awk '{print "  " $5}'
fi
echo ""

echo "=== Validation Complete ==="
echo ""
echo "Next steps:"
echo "  1. Transfer binary to target platform"
echo "  2. Ensure Julia libraries are available at runtime"
echo "  3. Run the binary and check Julia.init() succeeds"
