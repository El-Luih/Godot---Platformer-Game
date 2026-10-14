# (ae) = Already explained in another part of the code.
"""
Updates this label every frame to display the player's current health.
"""
extends Label

#Process functions (ae)
func _process(delta) -> void:
	#Health is a float (it drains every tick), so "int()" drops the decimals before "str()" turns it into text.
	text = "HP: " + str(int(Game.playerHP))
