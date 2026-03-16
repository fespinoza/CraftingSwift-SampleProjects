#!/bin/bash

# Install pykwalify (recommended for schema validation)
pip3 install pykwalify --break-system-packages

# Install yq (for structure validation)
brew install yq  # macOS
# or download from https://github.com/mikefarah/yq

# Install yamllint (for syntax validation)
pip3 install yamllint --break-system-packages
