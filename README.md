# Liquifly 💧

High-performance fluid simulation engine written in Rust with Flutter visualization.

## 🎯 Project Goals

Real-time simulation of viscous fluid composed of multiple bubbles with maximum performance and smooth animation. Physics accuracy is secondary to performance and smoothness.

## 🏗️ Architecture

**Monorepo structure:**
- `core/` - Rust physics engine (FFI library)
- `app/` - Flutter visualization application
- `tools/` - Build scripts and utilities
- `docs/` - Documentation

**Technology Stack:**
- **Rust** - Physics calculations, multi-threading (rayon), Spatial Hash Grid optimization
- **Flutter** - High-performance rendering with Canvas
- **FFI** - Bridge between Rust and Dart via `allo-isolate`

## 🚀 Quick Start

### Prerequisites

- Rust 1.90+ ([rustup](https://rustup.rs/))
- Flutter 3.7+ ([flutter.dev](https://flutter.dev/))
- VSCode with extensions (see `.vscode/extensions.json`)

### Setup

```bash
# Clone repository
git clone https://github.com/PlugFox/Liquifly.git
cd Liquifly

# Initialize (install components)
make init

# Check everything works
make check
```

### Build & Run

```bash
# Build Rust core
make build

# Run tests
make test

# Format and lint
make all

# Run Flutter app
make flutter-run
```

## 🛠️ Development

### VSCode Integration

The project is configured for VSCode with:
- Rust analyzer for `core/`
- Dart/Flutter support for `app/`
- Debug configurations (`.vscode/launch.json`)
- Build tasks (`.vscode/tasks.json`)

**Debug Rust:**
1. Open `core/` file
2. Press F5 or use "Debug Rust (core)" configuration

### Available Commands

```bash
make help         # Show all available commands
make check        # Quick check
make build        # Build dev
make build-release # Build optimized
make test         # Run tests
make fmt          # Format code
make clippy       # Lint code
make doc          # Generate docs
make clean        # Clean artifacts
```

### Project Structure

```
Liquifly/
├── core/               # Rust physics engine
│   ├── src/
│   │   ├── lib.rs     # FFI interface
│   │   ├── world.rs   # Main simulation
│   │   ├── physics/   # Physics calculations
│   │   ├── bridge/    # Dart FFI bindings
│   │   └── utils/     # Utilities
│   └── tests/         # Rust tests
│
├── app/                # Flutter app
│   ├── lib/
│   │   └── src/
│   │       ├── bridge/      # FFI integration
│   │       ├── simulation/  # Simulation controller
│   │       └── rendering/   # Canvas rendering
│   └── test/
│
├── tools/              # Scripts
└── docs/               # Documentation
```

## 📊 Performance Targets

- 10,000+ particles at 60 FPS
- Adaptive tick rate (60-120 Hz)
- Multi-threaded physics calculations
- Spatial Hash Grid for collision optimization
- Double buffering for smooth rendering

## 📝 API Design

See [CONCEPT.md](CONCEPT.md) for detailed API specification.

Key methods:
- `create()` - Initialize simulation
- `config()` - Configure parameters
- `impulse()` - Apply external forces
- `snapshot()` - Get current state
- `pause()/resume()` - Control simulation
- `dispose()` - Clean up resources

## 🧪 Testing

```bash
# Run all tests
make test

# Run specific test
cd core && cargo test test_name

# Run with output
cd core && cargo test -- --nocapture
```

## 📚 Documentation

```bash
# Generate and open docs
make doc

# Read concept
cat CONCEPT.md
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -am 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 👤 Author

**Mike Matiunin**
- GitHub: [@PlugFox](https://github.com/PlugFox)
- Email: plugfox@gmail.com
- Website: [plugfox.dev](https://plugfox.dev)

## 🔗 Links

- [Repository](https://github.com/PlugFox/Liquifly)
- [Concept Documentation](CONCEPT.md)
- [Issues](https://github.com/PlugFox/Liquifly/issues)
