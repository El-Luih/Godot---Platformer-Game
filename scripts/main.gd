# (ae) = Already explained in another part of the code.
#The starting function that initializes the game and the main menu scene.

extends Node2D

#Built-in virtual function (ae). Has no logic yet: "pass" is a placeholder that does nothing, since a function can't be empty.
func _ready():
	pass

#Sets "Button2" to quit the game when pressed.
func _on_button_2_pressed() -> void:
	#Selects the entirity of the game process with "get_tree()" and uses the method ".quit()" to kill it.
	get_tree().quit()

#Sets "Button2" to change to the "world.tscn" scene when pressed.
func _on_button_1_pressed() -> void:
	#Resets the global values of the "Utilities"/"Game" autoloads, so every new session starts from the default stats.
	Utilities.resetGlobalStats()
	#Uses the path to the specified scene file to change to that scene.
	get_tree().change_scene_to_file("res://scenes/world.tscn")
