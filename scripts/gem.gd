# (ae) = Already explained in another part of the code
# Item Tier: Level 1 Gem
"""
Collectible gem. Gives gold when the player touches it, hides itself and comes back after "RESPAWN_TIME" seconds.
It is an Area2D because it only needs to detect overlaps, not collide physically.
"""
extends Area2D

# A hardcoded constant was chosen instead of an export variable to keep the Inspector clean.
# This value was locked to 4.0 seconds specifically for the level one gem tier script.
const RESPAWN_TIME: float = 4.0 

var sprite
#Built-in virtual function (ae).
func _ready() -> void:
	# The animated sprite node reference. (ae)
	sprite = get_node("AnimatedSprite2D")

#Signal connection (ae). Triggers when a body enters this Area2D.
func _on_body_entered(body: Node2D) -> void:
	# Checks for the player character, whether it's already been collected, and whether it's visible.
	if body.name == "player_character" and sprite.animation != "collected" and visible:
		# Increases the gold score value by 5
		Game.gold += 5
		# Plays the collected animation and waits for it to end before continuing with the code
		sprite.play("collected")
		await sprite.animation_finished
		"""
		Instead of running queue_free() and deleting the node entirely from the world, a custom 
		cooldown loop was triggered. This "lazy spawner" approach was specifically chosen for 
		level design efficiency. Because dozens of gems had already been carefully manually positioned 
		across the map coordinates, a traditional marker-spawner system would have forced a complete 
		wipe and rebuild of the level layout from scratch. Toggling visibility and collision inside 
		the gem itself kept the map tree untouched and preserved all manual placement work.
		"""
		start_respawn_cooldown()

#Hides the gem, waits "RESPAWN_TIME" seconds and then respawns it, unless the game has ended.
func start_respawn_cooldown():
	# Makes the gem disappear without removing it from the scene tree.
	visible = false
	
	# Disables the collision shape safely and turns off physics detection at the end of the frame, 
	# Prevents physics engine crashes and stopping the player from collecting an invisible item.
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# An inline tree timer was chosen because it allowed this specific function to pause.
	# Waits out the cooldown cleanly in the background without locking up the rest of the game logic.
	await get_tree().create_timer(RESPAWN_TIME).timeout
	
	# Before bringing the gem back, verifies that the match has not ended. 
	# This prevents items from randomly popping back into existence during the game over screen.
	if not Game.gameOver:
		respawn_gem()

#Makes the gem visible and collectible again.
func respawn_gem():
	# Reverses the hidden cooldown states by bringing the graphics visibility back.
	visible = true
	# Turns the physical collision back on to detect the player character again.
	get_node("CollisionShape2D").set_deferred("disabled", false)
	# Resets the sprite back to its idle animation loop.
	sprite.play("idle")
