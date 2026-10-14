#(ae) = Already explained in another part of the code.
"""
Collectible cherry. It is dropped by defeated enemies, restores health when the player touches it and then deletes itself.
"""
extends Area2D
 
var sprite
#Built-in virtual function (ae).
func _ready() -> void:
	sprite = get_node("AnimatedSprite2D")
 
#Signal connection (ae).
func _on_body_entered(body: Node2D) -> void:
	#Name and "collected" checks (ae). The "collected" check prevents picking it up twice while the animation plays.
	if body.name == "player_character" and sprite.animation != "collected":
		#Restores 20 health. The player script caps health at 100 (see player_character.gd).
		Game.playerHP += 20
		sprite.play("collected")
		await sprite.animation_finished
		#Deletes the cherry once the "collected" animation ends (ae). Unlike gems, cherries don't respawn: each enemy death drops a new one.
		queue_free()
 
