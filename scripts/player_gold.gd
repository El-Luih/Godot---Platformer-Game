# (ae) = Already explained in another part of the code.
"""
Updates this label every frame to display the player's current gold.
"""
#Reads the gold from the global "Game" autoload (see Game script).
extends Label

#Process functions (ae)
func _process(delta) -> void:
	#"int()" removes any decimal part and "str()" converts the number into a string, so it can be joined with "Gold: ".
	text = "Gold: " + str(int(Game.gold))
