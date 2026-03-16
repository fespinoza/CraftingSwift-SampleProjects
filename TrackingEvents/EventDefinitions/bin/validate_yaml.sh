#!/bin/bash

# YAML Schema Validator for events.yaml
# Requires: yq and pykwalify (or ajv/yamllint as alternatives)

set -e

YAML_FILE="${1:-events.yaml}"
SCHEMA_FILE="${2:-events_schema.yaml}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==================================="
echo "YAML Schema Validation Script"
echo "==================================="
echo ""

# Check if YAML file exists
if [ ! -f "$YAML_FILE" ]; then
    echo -e "${RED}Error: YAML file '$YAML_FILE' not found${NC}"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Method 1: Using pykwalify (recommended for schema validation)
validate_with_pykwalify() {
    if ! command_exists pykwalify; then
        echo -e "${YELLOW}pykwalify not found. Install with: pip install pykwalify${NC}"
        return 1
    fi

    if [ ! -f "$SCHEMA_FILE" ]; then
        echo -e "${YELLOW}Schema file '$SCHEMA_FILE' not found${NC}"
        return 1
    fi

    echo "Method 1: Validating with pykwalify..."
    if pykwalify -d "$YAML_FILE" -s "$SCHEMA_FILE"; then
        echo -e "${GREEN}✓ Schema validation passed (pykwalify)${NC}"
        return 0
    else
        echo -e "${RED}✗ Schema validation failed (pykwalify)${NC}"
        return 1
    fi
}

# Method 2: Using yq for basic structure validation
validate_with_yq() {
    if ! command_exists yq; then
        echo -e "${YELLOW}yq not found. Install from: https://github.com/mikefarah/yq${NC}"
        return 1
    fi

    echo "Method 2: Validating with yq..."

    # Check if YAML is valid
    if ! yq eval '.' "$YAML_FILE" > /dev/null 2>&1; then
        echo -e "${RED}✗ Invalid YAML syntax${NC}"
        return 1
    fi

    # Check required top-level keys
    if ! yq eval '.tracking_locations' "$YAML_FILE" > /dev/null 2>&1; then
        echo -e "${RED}✗ Missing 'tracking_locations' key${NC}"
        return 1
    fi

    if ! yq eval '.tracking_events' "$YAML_FILE" > /dev/null 2>&1; then
        echo -e "${RED}✗ Missing 'tracking_events' key${NC}"
        return 1
    fi

    # Check if tracking_locations is an array
    if [ "$(yq eval '.tracking_locations | type' "$YAML_FILE")" != "!!seq" ]; then
        echo -e "${RED}✗ 'tracking_locations' must be an array${NC}"
        return 1
    fi

    # Check if tracking_events is an array
    if [ "$(yq eval '.tracking_events | type' "$YAML_FILE")" != "!!seq" ]; then
        echo -e "${RED}✗ 'tracking_events' must be an array${NC}"
        return 1
    fi

    # Check that all locations have an 'id' field
    missing_location_ids=$(yq eval '.tracking_locations[] | select(.id == null) | path | .[-1]' "$YAML_FILE")
    if [ -n "$missing_location_ids" ]; then
        echo -e "${RED}✗ Some tracking_locations are missing 'id' field${NC}"
        return 1
    fi

    # Check that all location IDs are unique
    duplicate_ids=$(yq eval '.tracking_locations[].id' "$YAML_FILE" | sort | uniq -d)
    if [ -n "$duplicate_ids" ]; then
        echo -e "${RED}✗ Duplicate tracking_location IDs found:${NC}"
        echo "$duplicate_ids"
        return 1
    fi

    # Check that location IDs are not longer than 40 characters
    long_location_ids=$(yq eval '.tracking_locations[] | select((.id | length) > 40) | .id' "$YAML_FILE")
    if [ -n "$long_location_ids" ]; then
        echo -e "${RED}✗ Some tracking_location IDs exceed 40 characters:${NC}"
        echo "$long_location_ids"
        return 1
    fi

    # Check that all events have a 'name' field
    missing_event_names=$(yq eval '.tracking_events[] | select(.name == null) | path | .[-1]' "$YAML_FILE")
    if [ -n "$missing_event_names" ]; then
        echo -e "${RED}✗ Some tracking_events are missing 'name' field${NC}"
        return 1
    fi

    # Check that event names are not longer than 40 characters
    long_event_names=$(yq eval '.tracking_events[] | select((.name | length) > 40) | .name' "$YAML_FILE")
    if [ -n "$long_event_names" ]; then
        echo -e "${RED}✗ Some tracking_event names exceed 40 characters:${NC}"
        echo "$long_event_names"
        return 1
    fi

    # Check that parameters are not longer than 40 characters
    long_parameters=$(yq eval '.tracking_events[] | select(.parameters != null) | .parameters[] | select(length > 40)' "$YAML_FILE")
    if [ -n "$long_parameters" ]; then
        echo -e "${RED}✗ Some parameters exceed 40 characters:${NC}"
        echo "$long_parameters"
        return 1
    fi

    # Validate platforms enum (if present)
    invalid_platforms=$(yq eval '.tracking_locations[] | select(.platforms != null) | .platforms[] | select(. != "ios" and . != "android")' "$YAML_FILE")
    if [ -n "$invalid_platforms" ]; then
        echo -e "${RED}✗ Invalid platform found in tracking_locations. Must be 'ios' or 'android'${NC}"
        echo "Invalid: $invalid_platforms"
        return 1
    fi

    invalid_platforms=$(yq eval '.tracking_events[] | select(.platforms != null) | .platforms[] | select(. != "ios" and . != "android")' "$YAML_FILE")
    if [ -n "$invalid_platforms" ]; then
        echo -e "${RED}✗ Invalid platform found in tracking_events. Must be 'ios' or 'android'${NC}"
        echo "Invalid: $invalid_platforms"
        return 1
    fi

    echo -e "${GREEN}✓ Basic structure validation passed (yq)${NC}"
    return 0
}

# Method 3: Using yamllint for syntax validation
validate_with_yamllint() {
    if ! command_exists yamllint; then
        echo -e "${YELLOW}yamllint not found. Install with: pip install yamllint${NC}"
        return 1
    fi

    echo "Method 3: Validating with yamllint..."
    if yamllint "$YAML_FILE"; then
        echo -e "${GREEN}✓ YAML syntax validation passed (yamllint)${NC}"
        return 0
    else
        echo -e "${RED}✗ YAML syntax validation failed (yamllint)${NC}"
        return 1
    fi
}

# Run all available validators
pykwalify_passed=0
yq_passed=0
yaml_lint_passed=0

# Try pykwalify first (most comprehensive)
if validate_with_pykwalify 2>&1; then
    pykwalify_passed=1
fi

echo ""

# Try yq validation (basic structure)
if validate_with_yq 2>&1; then
    yq_passed=1
fi

echo ""

# Try yamllint (syntax only)
if validate_with_yamllint 2>&1; then
  yaml_lint_passed=1
fi

if (( pykwalify_passed && yq_passed && yaml_lint_passed )); then
  exit 0
else
  exit 1
fi
