# (ae) = Already explained in another part of the code.
"""
Autoload script that stores the game's global data (player health and gold), 
so it can be read and modified from any other script.
"""
extends Node

#Current health of the player character. Starts at 100.
var playerHP = 100
#Amount of gold the player has collected. Starts at 0.
var gold = 0
#Number of enemies defeated in the session. Starts at 0.
var enemyScore = 0
#Flag that tells if the session has ended. Other scripts check it to stop acting (player, gems, timer). Starts as false.
var gameOver = false
#Seconds left in the session. Starts at 74. ": int" forces the variable to always hold an integer.
var time_left: int = 74
