"""
Script that holds the settings and functions for saving and loading the game's data.
"""
extends Node

"""
Path of the file where the game data will be saved.
"""
#"user://" points to a per-user folder that is always writable, also in exported builds.
const SAVE_PATH = "user://totallygenericsavegame.bin"


"""
Sets every global value back to its starting state. It has to be called before each session, 
since autoload values are not reset when a scene is reloaded. The numbers must match the defaults declared in game.gd.
"""
func resetGlobalStats():
	Game.playerHP = 100
	Game.gold = 0
	Game.enemyScore = 0
	Game.gameOver = false
	Game.time_left = 74

"""
Custom signal, declared with the "signal" keyword. It is emitted when the session ends, and other scripts 
connect functions to it (see game_over.gd and world.gd) so this script doesn't need to know about them.
"""
signal game_over_triggered
"""
Ends the session. It is called from the player script (health reached 0) and from world.gd (time ran out).
"""
func gameOver():
	#Guard: makes sure the ending only runs once, even if several things try to end the session.
	if Game.gameOver:
		return
	#The score is saved before the signal is emitted, so the game over screen already reads the updated best score.
	saveScore()
	#Marks the session as ended, which makes other scripts stop acting (ae).
	Game.gameOver = true
	#"emit()" triggers the signal, which calls every function connected to it.
	game_over_triggered.emit()
	

"""
Saves the current gold as the best score, only if it beats the stored one.
"""
func saveScore():
	if Game.gold <= loadBestScore():
		return
	#Opened for writing only after reading, since WRITE erases the file's contents.
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	#"JSON.stringify()" turns the dictionary into JSON text, which is written as one line. The file closes automatically when the function ends.
	save_file.store_line(JSON.stringify({"bestScore": Game.gold}))

"""
Returns the stored best score, or -1 if there is no valid save yet.
Using -1 means any score (even 0) is saved the first time.
"""
func loadBestScore() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return -1
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	#Reads the first line of the file and converts it from JSON text into a value.
	var data = JSON.parse_string(save_file.get_line())
	#"parse_string()" returns null on invalid or empty text, so the type is checked first.
	if data is Dictionary and data.has("bestScore"):
		#JSON numbers are parsed as floats, so "int()" converts it back.
		return int(data["bestScore"])
	return -1
