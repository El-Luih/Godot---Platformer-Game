"""
Game over screen. It is hidden by default and shown when the "game_over_triggered" signal of the "Utilities" autoload is emitted.
Displays the final stats of the session and lets the player restart or return to the main menu.
"""
extends CanvasLayer

# Keep paths clean by referencing relative to this UI canvas
"""
References to the labels and nodes used by this screen ("@onready" (ae)).
"$" is shorthand for "get_node()". The quotes are needed when the path has special characters, like ".." (ae), 
which here goes up to the parent and then down to a sibling node.
"""
@onready var time_label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/TimeLeft
@onready var hp_label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/HealthLeft
@onready var enemy_label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/EnemyScore
@onready var final_score_label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/ScoreVBox/FinalScore
@onready var best_score_label = $ColorRect/PanelContainer/MarginContainer/VBoxContainer/ScoreVBox/BestScore
@onready var game_over_music = $"../Sound/GameOverMusic"
@onready var game_ui = $"../InGameUI"

"""
Built-in virtual function (ae). Hides the screen at the start, so it only appears when the game ends.
"""
func _ready():
	visible = false
	"""
	"connect()" attaches a signal to a function from code, instead of doing it in the editor's Node tab.
	The function is passed without parentheses because it is being referenced, not called.
	"""
	# Connect directly to the global signal
	Utilities.game_over_triggered.connect(_on_game_over_triggered)

"""
Runs when "Utilities" emits "game_over_triggered". Fills the labels using the global "Game" autoload,
swaps the in-game UI for this screen and switches the music.
"""
func _on_game_over_triggered():
	# Update all metrics instantly from global states and passed parameter
	"""
	The "%" operator inserts a value into a string: "%d" is an integer and "%02d" is an integer padded with zeros 
	to two digits. If the value is a float, the decimal part is dropped, not rounded.
	"""
	time_label.text = "Time Left: %02ds" % Game.time_left
	hp_label.text = "Final HP: %d" % Game.playerHP
	enemy_label.text = "Enemies Defeated: %d" % Game.enemyScore
	final_score_label.text = "Gold Collected: %d" % Game.gold
	#Reads the best score stored in the save file (see "loadBestScore()" in the Utilities script).
	best_score_label.text = "Best Score: %d" % Utilities.loadBestScore()
	
	#Hides the in-game UI and shows this screen.
	game_ui.visible = false
	visible = true
	
	"""
	"get_node_or_null()" works like "get_node()", but returns null instead of raising an error if the node doesn't exist.
	The "if" below checks that it exists and is playing before stopping it.
	"""
	var bg_music = get_node_or_null("../Sound/BackgroundMusic")
	if bg_music and bg_music.playing:
		bg_music.stop()
	game_over_music.play()

#Signal connection (ae). Starts a new session.
func _on_restart_button_pressed() -> void:
	#Resets the global values first, since they live in an autoload and are not reset by reloading the scene.
	Utilities.resetGlobalStats()
	#Reloads the current scene from its file, which puts every node back in its starting state.
	get_tree().reload_current_scene()
	

#Signal connection (ae). Goes back to the main menu scene.
func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
