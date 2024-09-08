# FPS Project A (Template)

A looter-shooter game, built using the **Godot 4.3 game engine**, inspired by the Borderlands series with Procedurally generated weapons, gear, and loot with unique stats and effects.

## Table of Contents
- [Requirements](#requirements)
- [Setup](#setup)
- [Design Pattern](#design-pattern)
- [License](#license)

## Requirements
- **Godot Engine 4.3** (Download from [official website](https://godotengine.org/download))

## Setup
- Install Godot Engine 4.3
- Clone the repository
- Open Godot and import the project

**Game Controls**
- Use the mouse to aim and shoot.
- `WASD` to move.
- `E` to loot dropped items  with them.
- `TAB` to change weapons.
- `R` to reload
- `ESC` to toggle mouse capture

## Design Pattern
FPS Project A is built using a Redux-inspired design pattern. This pattern provides a clear separation between state and logic while minimizing resource usage.
- **CoreModel (State Machine):** The `CoreModel` class is state machine that runs separatly from the Godot Scene. It stores all state data of all non-static nodes excluding eye candy (e.g. bullet trails, animation states).
- **Game State Updates:** Nodes use the `on_core_changed()` instead of `_process()`, so they only react when a state change signal is emitted.

**Example Flow:**
- **State Change:** The player picks up and equips a gun from the floor and updates the inventory in `CoreModel`.
- **Signal Emit:** A `Signal` with a data payload of the event is emitted to all listening nodes.
- **Node Update:** The Game Scene and the UI reacts via their on_core_changed() method, removing the gun node from floor and updating the HUD to display information about the new gun.

## License
FPS Project A is licensed under the MIT License.
