.PHONY: help check build test clean fmt clippy doc all info init watch bindings

# Default target
help:
	@echo "Liquifly - Fluid Simulation Engine"
	@echo ""
	@echo "🔨 Build Commands:"
	@echo "  make check           - Quick check of Rust code"
	@echo "  make build           - Build Rust library (dev)"
	@echo "  make build-release   - Build optimized release"
	@echo "  make build-small     - Build smallest binary (~4.1 MB)"
	@echo "  make build-fast      - Build fastest runtime (fat LTO)"
	@echo "  make bindings        - Generate Dart FFI bindings"
	@echo ""
	@echo "🧪 Test Commands:"
	@echo "  make test            - Run all tests"
	@echo "  make bench           - Run benchmarks"
	@echo ""
	@echo "✨ Code Quality:"
	@echo "  make fmt             - Format code"
	@echo "  make fmt-check       - Check formatting"
	@echo "  make clippy          - Run clippy linter"
	@echo "  make all             - Format + lint + test"
	@echo ""
	@echo "📚 Documentation:"
	@echo "  make doc             - Generate and open docs"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make init            - Initialize project"
	@echo "  make info            - Show project info"
	@echo ""
	@echo "📱 Flutter Commands:"
	@echo "  make flutter-get     - Get Flutter dependencies"
	@echo "  make flutter-run     - Run Flutter app"
	@echo "  make flutter-build-apk  - Build Android APK"
	@echo "  make flutter-build-ios  - Build iOS app"
	@echo ""
	@echo "🎯 Quick Start:"
	@echo "  make init            - Initialize everything"
	@echo "  make run             - Build Rust + Generate bindings + Run Flutter"

# Quick check
check:
	@echo "🔍 Checking Rust code..."
	cd core && cargo check

# Build dev version
build:
	@echo "🔨 Building dev version..."
	cd core && cargo build

# Build release version
build-release:
	@echo "🚀 Building release version..."
	cd core && cargo build --release

# Build smallest binary
build-small:
	@echo "📦 Building smallest binary..."
	cd core && cargo build --profile release-small

# Build fastest binary
build-fast:
	@echo "⚡ Building fastest binary..."
	cd core && cargo build --profile release-fast

# Run tests
test:
	@echo "🧪 Running tests..."
	cd core && cargo test

# Run benchmarks
bench:
	@echo "📊 Running benchmarks..."
	cd core && cargo bench

# Format code
fmt:
	@echo "✨ Formatting code..."
	cd core && cargo fmt

# Check formatting without changes
fmt-check:
	@echo "🔍 Checking code formatting..."
	cd core && cargo fmt -- --check

# Run clippy
clippy:
	@echo "📎 Running clippy..."
	cd core && cargo clippy --all-targets -- -D warnings

# Generate documentation
doc:
	@echo "📚 Generating documentation..."
	cd core && cargo doc --no-deps --open

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cd core && cargo clean
	rm -rf app/.dart_tool app/build

# Run all checks
all: fmt clippy test
	@echo "✅ All checks passed!"

# Watch for changes and run checks
watch:
	@echo "👀 Watching for changes..."
	cd core && cargo watch -x check -x test

# Flutter tasks
flutter-get:
	@echo "📦 Getting Flutter dependencies..."
	cd app && flutter pub get

flutter-run:
	@echo "🏃 Running Flutter app..."
	cd app && flutter run

flutter-build-apk:
	@echo "📱 Building Android APK..."
	cd app && flutter build apk

flutter-build-ios:
	@echo "📱 Building iOS..."
	cd app && flutter build ios

# Initialize project (first time setup)
init:
	@echo "🎬 Initializing project..."
	@echo "Installing Rust toolchain..."
	rustup component add rustfmt clippy
	@echo "Getting Flutter dependencies..."
	cd app && flutter pub get
	@echo "Generating Dart bindings..."
	$(MAKE) bindings
	@echo "✅ Initialization complete!"

# Generate Dart FFI bindings from C header
bindings:
	@echo "🔗 Generating Dart FFI bindings..."
	cd app/packages/native && dart run ffigen --config ffigen.yaml

# Build Rust library and copy to native package
build-native: build
	@echo "📦 Copying Rust library to native package..."
	cd app/packages/native && dart bin/build.dart

# Build Rust library and generate bindings
prepare: build-native bindings

# Quick run: build + bindings + run Flutter
run: build-native bindings flutter-run

# Show project info
info:
	@echo "📊 Project Information"
	@echo "======================"
	@echo "Rust version:"
	rustc --version
	@echo ""
	@echo "Cargo version:"
	cargo --version
	@echo ""
	@echo "Flutter version:"
	flutter --version
