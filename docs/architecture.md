# Liquifly Architecture

## Overview

Liquifly is a high-performance fluid simulation system built with Rust and Flutter, optimized for real-time visualization of thousands of particles.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   UI Layer  │  │   Rendering  │  │  FFI Bridge      │   │
│  │             │  │   (Canvas)   │  │  (allo-isolate)  │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────┬───────────────────────────┘
                                  │ FFI
                    ┌─────────────┴─────────────┐
                    │                           │
┌───────────────────┴───────────────────────────┴─────────────┐
│                  Rust Physics Engine (core)                  │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │  World Manager   │  │  FFI Interface   │                 │
│  │  - State         │  │  - Dart API      │                 │
│  │  - Lifecycle     │  │  - SendPort      │                 │
│  └──────────────────┘  └──────────────────┘                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Physics Simulation Thread(s)               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │   │
│  │  │ Particles   │  │ Spatial     │  │ Collision   │  │   │
│  │  │ Update      │  │ Hash Grid   │  │ Detection   │  │   │
│  │  │ (parallel)  │  │             │  │ & Response  │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Physics Engine (Rust - `core/`)

**Responsibilities:**
- Particle state management
- Physics calculations (forces, velocities, positions)
- Collision detection and response
- Spatial optimization (Hash Grid)
- Multi-threaded computation

**Key Modules:**
- `world.rs` - Main simulation controller
- `physics/particle.rs` - Particle representation
- `physics/collision.rs` - Collision handling
- `physics/spatial_hash.rs` - Spatial optimization
- `bridge/dart_api.rs` - FFI interface

### 2. Flutter Application (`app/`)

**Responsibilities:**
- UI/UX
- Canvas rendering
- User input handling
- FFI communication
- State management

**Key Components:**
- `simulation_controller.dart` - FFI wrapper
- `bubble_painter.dart` - Canvas rendering
- `liquifly_bridge.dart` - Dart FFI bindings

## Data Flow

### Initialization
```
Flutter                      Rust
  │                           │
  ├─ init_dl_api() ──────────>│
  │                           │
  ├─ create(sendPort) ────────>│
  │                           ├─ Spawn simulation thread
  │                           ├─ Initialize world state
  │<──── return world_id ─────┤
  │                           │
  ├─ config(...) ─────────────>│
  │                           ├─ Set parameters
  │                           ├─ Allocate particles
  │                           └─ Start simulation loop
```

### Runtime Loop
```
Rust Thread              Rust Main          Flutter
     │                        │                │
     ├─ Update physics        │                │
     ├─ Calculate forces      │                │
     ├─ Resolve collisions    │                │
     ├─ Update positions      │                │
     │                        │                │
     ├─ notify via SendPort ─>│                │
     │                        ├─ signal ready ─>│
     │                        │                ├─ snapshot()
     │                        │<─ request data ─┤
     │                        ├─ copy buffer ──>│
     │                        │                ├─ render
     │                        │                │
     └─ (60 times/sec)        │                └─ (60-120 fps)
```

### Event Handling
```
Flutter                   Rust
  │                        │
  ├─ User tap              │
  ├─ impulse(x,y,force) ──>│
  │                        ├─ Apply force to nearby particles
  │                        └─ Continue simulation
```

## Performance Optimization

### 1. Spatial Hash Grid

Divides world into cells for fast neighbor lookup:
- O(1) cell lookup
- Only check particles in adjacent cells
- Reduces collision checks from O(n²) to O(n)

### 2. Parallelization

Using Rayon for data parallelism:
- Particle updates in parallel
- Grid construction in parallel
- Collision resolution by independent cell groups

### 3. Memory Layout

- Struct of Arrays (SoA) for better cache locality
- Double buffering for read/write separation
- Pre-allocated buffers to avoid runtime allocations

### 4. Rendering

- `Canvas.drawRawPoints()` for batch rendering
- Float32List for efficient data transfer
- Minimal Flutter-Rust communication overhead

## Threading Model

```
Main Thread (Dart)
  │
  ├─ UI Event Loop
  ├─ Widget Rendering
  └─ FFI Calls (non-blocking)

Rust Thread Pool
  │
  ├─ Simulation Thread (dedicated)
  │   └─ Physics loop @ 60 Hz
  │
  └─ Rayon Worker Threads
      ├─ Particle updates
      ├─ Grid construction
      └─ Collision resolution
```

## Memory Management

### Rust Side
- Owned by World struct
- Uses `Box<[Particle]>` for heap allocation
- Manual lifecycle via `dispose()`

### Dart Side
- FFI pointer handles
- `Float32List.view()` for zero-copy access
- Automatic cleanup via finalizers

## Error Handling

### Rust
- `Result<T, E>` for recoverable errors
- Panic on critical failures (caught at FFI boundary)
- Validation of all inputs

### Flutter
- Exception catching at FFI boundary
- User-friendly error messages
- Graceful degradation

## Configuration

### Compile-Time
- `Cargo.toml` - Rust features and dependencies
- Profile settings for optimization levels

### Runtime
- `config()` API for dynamic parameters
- Adaptive quality based on performance

## Future Enhancements

1. **GPU Acceleration** - Compute shaders for physics
2. **Advanced Physics** - SPH fluid simulation
3. **Visual Effects** - Metaballs, lighting, shadows
4. **Networking** - Multi-user simulation
5. **Recording** - Export simulation as video

## See Also

- [CONCEPT.md](../CONCEPT.md) - Project concept and API
- [README.md](../README.md) - Getting started guide
