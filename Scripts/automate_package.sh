#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$PROJECT_ROOT"

echo "[ColorsKit Automation] Starting..."

# Initialize package if missing (skip if already present)
if [[ ! -f "Package.swift" ]]; then
  echo "Initializing Swift package ColorsKit"
  swift package init --name ColorsKit --type library
fi

# Build & Test (SPM)
echo "Running swift build"
swift build

echo "Running swift test"
swift test

# Generate docs with jazzy if installed
if command -v jazzy >/dev/null 2>&1; then
  echo "Generating docs with jazzy"
  jazzy --module ColorsKit --output "$PROJECT_ROOT/docs" || true
else
  echo "[Skip] jazzy not found; install with 'gem install jazzy'"
fi

# CocoaPods setup: ensure podspec exists
if [[ ! -f "ColorsKit.podspec" ]]; then
  echo "Creating ColorsKit.podspec"
  cat > ColorsKit.podspec <<'PODSPEC'
Pod::Spec.new do |s|
  s.name             = 'ColorsKit'
  s.version          = '0.1.0'
  s.summary          = 'Comprehensive color management for iOS: hex APIs, theming, accessibility, gradients.'
  s.description      = 'ColorsKit simplifies color usage in iOS apps with hex parsing, dynamic colors, accessibility checks, palette generation, gradients, and simulators.'
  s.homepage         = 'https://example.com/ColorsKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :git => 'https://github.com/your/repo.git', :tag => s.version.to_s }
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'
  s.source_files     = 'Sources/**/*.{swift}'
  s.requires_arc     = true
end
PODSPEC
fi

# Validate podspec locally if CocoaPods is installed
if command -v pod >/dev/null 2>&1; then
  echo "Validating podspec"
  pod lib lint --allow-warnings || true
  echo "[Info] To register trunk: pod trunk register you@example.com 'Your Name'"
  echo "[Info] To push: pod trunk push ColorsKit.podspec"
else
  echo "[Skip] CocoaPods not found; install with 'sudo gem install cocoapods'"
fi

# Setup GitHub Actions CI if missing
if [[ ! -f ".github/workflows/ci.yml" ]]; then
  echo "Creating GitHub Actions CI workflow"
  mkdir -p .github/workflows
  cat > .github/workflows/ci.yml <<'YAML'
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest
      - name: Swift Build
        run: swift build
      - name: Swift Test
        run: swift test
YAML
fi

# Setup Fastlane if installed
if command -v fastlane >/dev/null 2>&1; then
  echo "Setting up Fastlane"
  mkdir -p fastlane
  cat > fastlane/Fastfile <<'FASTFILE'
fastlane_version '2.220.0'

default_platform(:ios)

platform :ios do
  desc "Run swift build & test"
  lane :ci do
    sh("swift build")
    sh("swift test")
  end
end
FASTFILE
else
  echo "[Skip] Fastlane not found; install with 'gem install fastlane'"
fi

echo "[ColorsKit Automation] Done."