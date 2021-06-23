#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$DIR/.."
EXAMPLE_APP_DIR="$PROJECT_DIR/packages/glopos/example"
EXAMPLE_APP_BUILD_WEB_DIR="$EXAMPLE_APP_DIR/build/web"
DOCS_EXAMPLE_APP_DIR="$PROJECT_DIR/docs/glopos_example"

cd "$EXAMPLE_APP_DIR"
flutter build web --source-maps

rm -rf "$DOCS_EXAMPLE_APP_DIR"
cp -R "$EXAMPLE_APP_BUILD_WEB_DIR/" "$DOCS_EXAMPLE_APP_DIR"
