# Overview

As a software engineer, I wanted to build a complete, playable game from start to finish in order to practice the parts of software development that go beyond writing individual functions: structuring a project into reusable scenes, managing shared state, communicating between components with events, saving data between runs, and shipping a build that works outside the editor.

**Totally Generic Retro Platformer** is a 2D, timed arcade platformer made in Godot. Every session lasts exactly **74 seconds**. The goal is to collect as much gold as possible before the time runs out or your health reaches zero. Your health drains constantly during the session, so you cannot just stay on the safe platforms forever. You have to come down to the floor, where the enemies are, to recover health.

**How to play**

- **Move:** Left and Right arrow keys.
- **Jump:** Space or Enter.
- **Gems:** floating platforms are split into three levels, and the higher the platform, the more valuable (and harder to reach) the gems are.
  - Level 1 (closest to the floor): worth 5 points, 40 gems.
  - Level 2 (middle): worth 10 points, 20 gems.
  - Level 3 (top): worth 40 points, 16 gems.
- **Enemies:** frogs patrol the floor, wandering left and right. When you enter their detection area, they start chasing you.
  - Land on top of an enemy to defeat it.
  - If an enemy touches you without being stomped, you lose 30% of your health, and the enemy dies as well.
  - Defeated enemies drop a cherry that restores 20 health.
- **Respawning:** gems and enemies come back after a fixed time, always in the same positions, so a good route is worth repeating.
- **Game over:** the session ends when time runs out or your health reaches zero. The game over screen shows your time left, final health, enemies defeated, gold collected, and your best score, which is saved between sessions. From there you can restart or return to the main menu.

**Purpose**

My purpose for writing this software was to learn how a real-time game is put together using an engine, and to apply that knowledge in a project small enough to finish but complete enough to include every stage: menus, gameplay, enemy behavior, persistence, polish, and export. It also gave me practice documenting my code so that someone else (or me, months from now) can understand why each piece exists.

# Video Demo

A demonstration of the game being played is available at the link below. A video explaining the code is available on request.

# Development Environment

- **Engine:** Godot 4.7.2 (stable, .NET/mono edition, although no C# is used).
- **Editor:** the Godot editor for scenes, animation, collision shapes, and scripts.
- **Export:** Godot's export templates, producing a single Windows `.exe` with the PCK embedded and debug disabled.
- **Language:** GDScript.
- **Libraries:** none external. The project only uses Godot's built-in nodes and classes, including `CharacterBody2D`, `Area2D`, `AnimationPlayer`, `AnimatedSprite2D`, `ParallaxBackground`, `Timer`, `CanvasLayer`, `FileAccess`, and `JSON`. It also includes a small custom `canvas_item` shader for tinting sprites.
- **Project structure:**
  - Autoload scripts (`Game` for shared session data and `Utilities` for ending the session and saving/loading the best score).
  - Separate scenes for the main menu, the world, the player, the enemy, the parallax background, and each collectible (three gem tiers and cherries).

# Useful Websites

- [Godot Docs](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [Using CharacterBody2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html)
- [Using Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [File Paths in Godot Projects (res:// and user://)](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)
- [FileAccess Class Reference](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)
- [Shading Language Reference](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html)
- [Exporting for Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html)

# Future Work

- Hide negative health on the HUD: the HP label can briefly show a negative number while the death animation plays.
- Move hardcoded values (enemy damage, cherry healing, gem points, drain speed) into constants in the `Game` autoload, so the game can be balanced from one place.
- Merge the three gem scripts into one, using exported variables for the value and respawn time.
- Add more enemy types and more level variations.
- Add a pause menu, volume settings, and controller support.
