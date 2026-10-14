# (ae) = Already explained in another part of the code
"""
Item Tier: Level 2 Gem. 
- Increased score rewards.
- Harder difficulty for the platforming required to do in order to reach it.
- Increased respawning time.
"""
extends Area2D

# Respawn hardcoded constant for seconds (ae)
const RESPAWN_TIME: float = 6.0 

var sprite
#Built-in virtual function (ae).
func _ready() -> void:
	# The animated sprite node reference. (ae)
	sprite = get_node("AnimatedSprite2D")

#Signal connection (ae).
func _on_body_entered(body: Node2D) -> void:
	#Checks player character, collected animation, and visibility (ae)
	if body.name == "player_character" and sprite.animation != "collected" and visible:
		#Gold score +10 (ae)
		Game.gold += 10
		# Collected animation and await logic (ae)
		sprite.play("collected")
		await sprite.animation_finished
		# Starts respawning logic (ae)
		start_respawn_cooldown()

#Hide, wait and respawn (ae).
func start_respawn_cooldown():
	# Dissappears gem (ae)
	visible = false
	
	# Disables collision and physics (ae)
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# Iniline tree timer that tracks respawning cooldown (ae)
	await get_tree().create_timer(RESPAWN_TIME).timeout
	
	# Game over verification before respawning (ae)
	if not Game.gameOver:
		respawn_gem()

#Makes the gem collectible again (ae).
func respawn_gem():
	# Brings back visibility, logic, visibility, and idle animation (ae)
	visible = true
	get_node("CollisionShape2D").set_deferred("disabled", false)
	sprite.play("idle")
