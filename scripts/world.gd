# (ae) = Already explained in another part of the code.
#The controller of the "world" scene

extends Node2D

#Node references (ae). "PlayerTime" is the label that shows the time left and "TimeLeft" is a Timer node.
@onready var timer_label = $InGameUI/PlayerTime
@onready var game_timer = $TimeLeft

"""
Built-in virtual function (ae). Shows the initial time and connects the "game_over_triggered" signal of "Utilities" 
to "local_game_over()" (see game_over.gd).
"""
func _ready():
	update_timer_display()
	Utilities.game_over_triggered.connect(local_game_over)

#Writes the time left into the label. "%02d" pads it with zeros to two digits (ae).
func update_timer_display():
	timer_label.text = "%02d" % Game.time_left

"""
Signal connection (ae), from the "timeout" signal of the "TimeLeft" Timer, which is emitted when its wait time runs out.
Each timeout is one second of the session: it subtracts 1 from "Game.time_left" and updates the label.
"""
func _on_time_left_timeout() -> void:
	if Game.time_left > 0 and not Game.gameOver:
		Game.time_left -= 1
		update_timer_display()
		
		if Game.time_left > 0 and not Game.gameOver:
			#Starts the timer again for another second. This is what makes the countdown repeat if the Timer is set to "One Shot".
			game_timer.start(1.0)
		else:
			#Reached when the time hits 0. "Utilities.gameOver()" ends the session (see utilities.gd).
			Utilities.gameOver()

"""
Runs when the game ends for any reason (time out or death). Stops the timer, 
and shows "00" in the label if it ended because the time ran out.
"""
func local_game_over():
	game_timer.stop()
	if Game.time_left <= 0:
		timer_label.text = "00"
