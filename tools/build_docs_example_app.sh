#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$DIR/.."
EXAMPLE_APP_DIR="$PROJECT_DIR/packages/glopos/example"
EXAMPLE_APP_BUILD_WEB_DIR="$EXAMPLE_APP_DIR/build/web"
DOCS_EXAMPLE_APP_DIR="$PROJECT_DIR/docs/glopos_example"

cd "$EXAMPLE_APP_DIR"
# TODO: enable service worker for live demo
# Service worker is currently broken for apps not hosted at the server root.
# https://github.com/flutter/flutter/issues/68449 
flutter build web --pwa-strategy none

rm -rf "$DOCS_EXAMPLE_APP_DIR"
cp -R "$EXAMPLE_APP_BUILD_WEB_DIR/" "$DOCS_EXAMPLE_APP_DIR"
