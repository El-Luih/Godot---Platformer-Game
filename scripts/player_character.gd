# (ae) = Already explained in another part of the code.
#The controller for the player character's behavior.

extends CharacterBody2D

#Defines the regular horizontal speed in pixels per second. 
# It is positive because it will be multiplied by a direction (-1, 0 or 1).
const SPEED_REG = 300.0
#Defines the velocity applied upwards when triggering a jump, in pixels per second.
#Must be negative because the y-axis points downwards by default.
const JUMP_VELOCITY = -400.0

"""
"@onready" delays this assignment until the node and all its children are ready in the scene tree.
This is needed because "get_node()" can only find a child that already exists.
"get_node("AnimationPlayer")" searches for a node by its path relative to this one. 
A plain name looks for a direct child.
"""
"""
NOTE: despite its name, "sprite" holds the AnimationPlayer node, not the AnimatedSprite. 
Animations ("idle", "run", "jump"...) are played through it, while the horizontal flip is applied to the "AnimatedSprite" node.
"""
@onready var sprite = get_node("AnimationPlayer")


"""
Built-in virtual function. Overriding it lets the node run its own physics code. 
The engine calls it automatically once every physics tick (by default, 60 times per second).

"delta" is the time in seconds that has passed since the previous physics tick. With the default 
settings, it is constant and equal to 1 / Engine.physics_ticks_per_second.

Multiplying per-second quantities (like acceleration) by "delta" makes the resulting movement
independent of the physics tick rate: the object covers the same distance per real-time second
no matter how many ticks are used to get there.
"""
func _physics_process(delta: float) -> void:
	"""
	Stops all processing once the session has ended, so the player can't move or lose health during the game over screen.
	"return" exits the function immediately. "Game" is the global autoload (see Game script).
	"""
	if Game.gameOver:
		return
	#Caps health at the maximum, since healing can push it above 100.
	if Game.playerHP > 100:
		Game.playerHP = 100
		
	"""
	"current_animation" is the name of the animation the AnimationPlayer is playing right now.
	While "dead" plays, the function exits early, so the player can't move or lose more health (see the death logic below).
	"""
	if sprite.current_animation == "dead":
		return
	"""
	# A dynamic calculation was implemented to drain exactly 4 times the maximum health over a 74-second session.
	# Assuming a default maximum health of 100, a value of 400 total HP was divided by 74 seconds.
	# Multiplying by delta ensured a smooth, frame-rate independent depletion every single frame tick.
	"""
	#The decimals ("400.0", "74.0") matter: with integers, GDScript would do an integer division and drop the decimal part.
	var health_drain: float = 400.0 / 74.0
	#Drains health every physics tick, scaled by "delta" (ae).
	Game.playerHP -= health_drain * delta
	
	"""
	Applies gravity while the body is in the air.
	
	"get_gravity()" returns the gravity vector affecting this body, based on the project's default 
	gravity settings (and any Area2D overrides). Gravity is an acceleration (pixels per second squared), 
	so it is multiplied by "delta" to get the change in velocity for this tick, 
	and then added to the body's built-in "velocity" property.

	A "floor" is defined by the following values (editable within the game-engine GUI):
		- The maximum allowed angle of a "surface" (floor_max_angle)
		- The direction of the "up" vector (up_direction)
	"""
	if not is_on_floor():
		velocity += get_gravity() * delta

	"""
	Detects when the button associated to the action "ui_accept" (pressing Space or Enter) 
	has been pressed during this exact tick, not during the potential subsequent ticks the button may be held down.
	This will only be detectable again after the button is released and pressed again.
	
	It then checks whether the player character is on top of an acceptable floor surface. 
	Only then is the jump code processed, which prevents jumping while in the air.
	"""
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#Sets the vertical velocity to "JUMP_VELOCITY", replacing whatever value it had before.
		#Only the y component is changed, so horizontal velocity is left untouched.
		velocity.y = JUMP_VELOCITY
		#Plays the "jump" animation through the AnimationPlayer.
		sprite.play("jump")

	"""
	Gets a one-axis direction from the actions specified, triggered by their associated inputs.
	In "Input.get_axis(neg, pos)", the first parameter is the negative side of the axis, 
	the second one is the positive side.
	
	The strength of the negative action is subtracted from the strength of the positive one and the 
	result is returned and stored as "direction". Strengths go from 0 to 1 (digital inputs like keys 
	are always either 0 or 1).
	
	In this case, "ui_left" gives -1 and "ui_right" gives 1 when fully pressed.
	If only one is pressed, a direction to move is given.
	If both are pressed at the same time, they cancel each other out and the result is 0.
	"""
	var direction = Input.get_axis("ui_left", "ui_right")
	
	"""
	"flip_h" mirrors the sprite horizontally. Mirroring defaults to false.
	
	It is set to true when the player is looking to the left (negative x).
	It is reset to false when the player is looking to the right (positive x).
	"""
	#"direction" is a float, but keyboard inputs only give exactly -1, 0 or 1, so comparing with "==" is safe here.
	if direction == -1:
		get_node("AnimatedSprite").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite").flip_h = false
	
	#If a direction is provided through inputs (any non-zero value), x-axis velocity is set to that direction multiplied by SPEED_REG.
	if direction:
		velocity.x = direction * SPEED_REG
		"""
		Plays "run" only if there is no vertical movement, so it doesn't override the "jump" or "fall" animations in the air.
		Here, "velocity.y == 0" is used as a check for being on the ground.
		"""
		if velocity.y == 0:
			sprite.play("run")
	#If no direction is provided, the x-axis velocity is reduced towards 0 by at most SPEED_REG each tick.
	#Since SPEED_REG equals the maximum horizontal speed, the body stops instantly.
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_REG)
		#Same ground check (ae), this time for the "idle" animation.
		if velocity.y == 0:
			sprite.play("idle")
	
	"""
	A positive y velocity means moving downwards (the y-axis points down), so the "fall" animation is played.
	It comes after the checks above, so it replaces "run" or "idle" while falling.
	"""
	if velocity.y > 0:
		sprite.play("fall")
	
	#Death check. Health drains every tick, so this is reached once it drops to 0 or below.
	if Game.playerHP <=0:
		#Calls the dead animation and waits for it to finish before trigerring the game over state.
		sprite.play("dead")
		"""
		"await" (ae) pauses only this function. Meanwhile, the next physics ticks exit early at the "dead" animation check 
		at the top, so this block doesn't run twice. When the animation ends, health is set to exactly 0 (it could be slightly 
		below it) and "Utilities.gameOver()" is called (see Utilities script).
		"""
		await sprite.animation_finished
		Game.playerHP = 0
		Utilities.gameOver()
	"""
	Built-in function. Moves the body using its current "velocity" (in pixels per second, so "delta" 
	is already taken into account internally and must not be multiplied again).
	
	When the body collides with something, it slides along the surface instead of stopping, 
	and "velocity" is updated to reflect the motion that remains after the collision. 
	It also updates the information used by functions like "is_on_floor()", "is_on_wall()" 
	and "is_on_ceiling()".
	
	Standing on a moving platform automatically adds the platform's velocity to the body's movement.
	
	Should be called inside "_physics_process(delta)" of a Node.
	
	Behavior and properties vary according to the "motion_mode" value (Grounded or Floating).
	"""
	move_and_slide()
