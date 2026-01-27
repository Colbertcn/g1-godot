# 2D Vehicle Shooter (Godot 4)

A simple 2D vehicle shooting project developed in Godot 4.

## How to Play
- **Up Arrow**: Move Forward
- **Down Arrow**: Move Backward
- **Left Arrow**: Rotate Left
- **Right Arrow**: Rotate Right
- **Space / Left Mouse Click**: Shoot

*Note: You can add WASD support in Godot's Project Settings -> Input Map.*

## Project Structure
- `scenes/`: Contains Godot scenes (`.tscn`).
  - `main.tscn`: The main game world.
  - `player.tscn`: The player vehicle.
  - `bullet.tscn`: The bullet fired by the player.
- `scripts/`: Contains GDScript files (`.gd`).
  - `player.gd`: Movement and shooting logic.
  - `bullet.gd`: Bullet movement and collision logic.
