# (ae) = Already explained in another part of the code.
# Controls the behavior of the frog enemy

extends CharacterBody2D

# A hardcoded constant was chosen to manage the respawn timing entirely in code.
# This value was locked to 6.0 seconds for the enemy cooldown duration.
const RESPAWN_TIME: float = 6.0
"""
"preload()" loads the scene file when the script is loaded, instead of when it is needed, and returns a PackedScene.
A PackedScene is a template: "instantiate()" creates a new copy of it each time it is called.
"""
# The cherry scene path was stored to instantiate item drops dynamically upon enemy defeat.
const CHERRY_SCENE = preload("res://scenes/items/cherry.tscn") 

#Placeholder variable with no assigned value yet (null). It will hold the player node once chasing starts.
var player
#Flag that tells the physics tick whether the enemy should currently chase the player.
var chase = false
#Enemy speed in px/s (ae)
var SPEED = 180
#Placeholder variable. It will hold the sprite node once it's fully loaded.
var sprite
#"Vector2" is a pair of x and y values, used here to store a position.
# A backup vector variable was implemented to lock down the exact spot where the frog spawned.
# This allowed the enemy to return to its original map location whenever it respawned.
var initial_spawn_position: Vector2

"""
Wandering state: "is_waiting" tells if the enemy is standing still or moving, and "wander_direction" is
-1.0 (left), 0.0 (still) or 1.0 (right). "$DirectionTimer" is shorthand for "get_node()" (ae).
"""
# Component path references and movement state tracking variables were introduced for the wandering behavior
# Wandering behavior is the random movement of the enemy while not actively chasing the player.
@onready var direction_timer = $DirectionTimer
var is_waiting: bool = false
var wander_direction: float = 0.0

"""
Built-in virtual function. Called once, when this node and its children have entered the scene tree
and are ready. (ae)
"""
func _ready():
	# Selects the animated sprite and plays the idle animation on load.
	sprite = get_node("AnimatedSprite2D")
	sprite.play("idle")
	#"global_position" is the position in the world, unlike "position", which is relative to the parent node.
	# The initial position layout vectors were saved right on frame one.
	initial_spawn_position = self.global_position
	# Starts wandering behavior
	start_wander_move()

#Physics tick initializer (ae)
func _physics_process(delta: float) -> void:
	# Stops physics processing when the game is over.
	if Game.gameOver:
		return
	"""
	"visible" tells if the node is drawn. Since the enemy is hidden (not deleted) while it respawns, 
	it also works here as an "is active" flag.
	"""
	# While the "dead" animation is selected or the node is invisible during its respawning cooldown, behavior is skipped.
	if sprite.animation != "dead" and visible:
		#Gravity logic (ae)
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		if chase:
			"""
			In a path, ".." means "the parent node". Each ".." goes up one level of the tree, 
			and then the path goes down through "Player" to "player_character".
			"""
			player = get_node("../../Player/player_character")
			"""
			Subtracting the enemy's position from the player's position gives a vector that points 
			from the enemy to the player. "normalized()" shrinks it to a length of 1, 
			so only its direction is kept and not the distance. "self" is this node.
			"""
			var direction = (player.position - self.position).normalized()
			
			#Calls the jump animation (does not restart with every tick if it's currently playing)
			sprite.play("jump")
			
			#Mirrors the sprite to face the player (faces left by default)
			if direction.x > 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			
			#Horizontal velocity (ae)
			velocity.x = direction.x * SPEED
		else:
			#Wandering (not chasing): it either stands still while waiting, or moves in the "wander_direction".
			if is_waiting:
				velocity.x = 0
				sprite.play("idle")
			else:
				velocity.x = wander_direction * (SPEED * 0.6) # Wanders slightly slower than chasing speed
				sprite.play("jump")
				#Flips to face the movement direction (ae). "elif" is used instead of "else" so a direction of 0 leaves the flip as it is.
				if wander_direction > 0:
					sprite.flip_h = true
				elif wander_direction < 0:
					sprite.flip_h = false
	#Enables movement (ae)
	move_and_slide()

"""
Starts a movement period of 1 second towards a random direction.
"randf()" returns a random float between 0.0 and 1.0, so "> 0.5" is a 50/50 chance. 
"1.0 if condition else -1.0" is an inline conditional that picks one of the two values.
When the timer ends, "_on_direction_timer_timeout()" switches to the waiting period.
"""
func start_wander_move():
	#Does nothing if the game ended or the enemy is dead or hidden, so the wander cycle can't restart in those states.
	if Game.gameOver or sprite.animation == "dead" or not visible:
		return
	is_waiting = false
	
	wander_direction = 1.0 if randf() > 0.5 else -1.0
	direction_timer.start(1.0)

#Starts a waiting period of 3 seconds, in which the enemy stands still.
func start_wander_wait():
	#Same guard (ae).
	if Game.gameOver or sprite.animation == "dead" or not visible:
		return
	is_waiting = true
	wander_direction = 0.0
	direction_timer.start(3.0)

"""
Signal connection (ae), from the "timeout" signal of "DirectionTimer". Each period restarts the timer with its own duration, 
so the enemy alternates between moving (1 s) and waiting (3 s).
"""
func _on_direction_timer_timeout() -> void:
	if not is_waiting:
		start_wander_wait()
	else:
		#Goes back to wandering, since the chase is over.
		start_wander_move()

#Signal that triggers whenever a body has entered the designated "PlayerDetector" 2D Area.
func _on_player_detector_body_entered(body) -> void:
	#Checks the name of the body. Must match the player character's node name.
	if body.name == "player_character" and visible and sprite.animation != "dead":
		chase = true
		#Stops the wander cycle, since the chase now controls the movement.
		direction_timer.stop()


"""
Signal that triggers only when the player character has left the "ChaseRange" Area, which is larger 
than the "PlayerDetector" Area.

Stops the chase after detection.
"""
func _on_chase_range_body_exited(body) -> void:
	if body.name == "player_character" and visible and sprite.animation != "dead":
		chase = false
		start_wander_move()

#Function that describes the behavior this character should follow when "dying".
func death():
	#Adds 1 to the defeated enemies counter, shown in the game over screen.
	Game.enemyScore += 1
	#Changes the chase status back to false and velocity to 0 to stop movement.
	chase = false
	direction_timer.stop()
	velocity.x = 0
	#Plays the "dead" animation
	sprite.play("dead")
	
	"""
	"await" pauses only this function until the "dead" animation finishes. The rest of the game keeps running.
	Then "self.queue_free()" deletes this node at the end of the current frame.

	While the animation plays, the "if" in the physics tick function skips the behavior and movement logic, 
	so those can't replace the "dead" animation with another one (which would make the enemy immortal).
	
	The "dead" animation is also set not to loop.
	"""
	await sprite.animation_finished
	
	# The cherry instance creation block was executed exactly as the death graphics concluded.
	var cherry_instance = CHERRY_SCENE.instantiate()
	"""
	"get_nodes_in_group()" returns an array with every node added to that group (Node tab > Groups).
	Groups allow finding nodes without knowing their path.
	"""
	# Gets the "Cherries" 2D Node inside the world scene and the new group inside it to spawn the cherries on enemy death
	var cherries_folders = get_tree().get_nodes_in_group("cherries_container")
	if cherries_folders.size() > 0:
		"""
		A new instance is not part of the game until "add_child()" adds it to the scene tree as a child of a node. 
		"[0]" is the first element of the array.
		"""
		# Adds the cherry instance to the node inside the "cherries_container" group
		cherries_folders[0].add_child(cherry_instance)
		# Sets the global position of the newly created cherry to match the current position of the dead enemy 
		cherry_instance.global_position = self.global_position
	else:
		# Fallback in case no cherroes_container group is found. Messy, but secure.
		#"current_scene" is the root node of the scene that is running (here, "World").
		get_tree().current_scene.add_child(cherry_instance)
		cherry_instance.global_position = self.global_position
		# Console warning for debugging.
		print("Warning: cherries_container group not found!")
	# Instead of running queue_free(), an inline respawn cooldown sequence was initiated.
	# This mirrored the lazy spawner approach used in the gem system to avoid resetting tree nodes manually.
	start_respawn_cooldown()
	
func start_respawn_cooldown():
	# To make the enemy disappear without wiping its variables, the graphics were turned off.
	visible = false
	
	# Every single collision monitoring box and hitbox area layer was toggled off dynamically.
	# Using set_deferred ensured that physics queries wouldn't crash mid-frame, preventing the 
	# invisible ghost frog from tracking, blocking, or damaging the player character.
	#Disables each shape at the end of the frame ("set_deferred", see gem scripts). "PlayerDetector/CollisionShape2D" is a path through the child Area2D to its shape.
	get_node("BodyHitbox").set_deferred("disabled", true)
	get_node("PlayerDetector/CollisionShape2D").set_deferred("disabled", true)
	get_node("ChaseRange/CollisionShape2D").set_deferred("disabled", true)
	get_node("DamageHitbox/CollisionShape2D").set_deferred("disabled", true)
	get_node("AttackHitbox/CollisionShape2D").set_deferred("disabled", true)
	
	# An inline background system timer was chosen to count down the cooldown safely.
	await get_tree().create_timer(RESPAWN_TIME).timeout
	
	# A boundary check confirmed the game was still active before triggering regeneration.
	if not Game.gameOver:
		respawn_enemy()

func respawn_enemy():
	# The frog's global position was snapped back to its initial map loading coordinates.
	self.global_position = initial_spawn_position
	#Clears any leftover velocity. "Vector2.ZERO" is the vector (0, 0).
	velocity = Vector2.ZERO
	
	# The visibility flag was toggled back to true to draw the frog on screen again.
	visible = true
	
	# All physical collision monitoring systems were safely re-activated.
	get_node("BodyHitbox").set_deferred("disabled", false)
	get_node("PlayerDetector/CollisionShape2D").set_deferred("disabled", false)
	get_node("ChaseRange/CollisionShape2D").set_deferred("disabled", false)
	get_node("DamageHitbox/CollisionShape2D").set_deferred("disabled", false)
	get_node("AttackHitbox/CollisionShape2D").set_deferred("disabled", false)
	
	# State tracking flags and standard animation sequences were restored to defaults.
	sprite.play("idle")
	start_wander_move()

"""
Signal that triggers only when the player character manages to contact the "DamageHitbox" Area of this 
enemy character, which is much smaller than the collision area and can only be reached by landing "on top" of 
the enemy.

Calls the "death()" function.
"""
func _on_damage_hitbox_body_entered(body) -> void:
	if body.name == "player_character" and sprite.animation != "dead" and visible:
		death()

"""
Signal that triggers when the player character contacts the "AttackHitbox" Area of this enemy.
Unlike the "DamageHitbox", touching this one hurts the player.

If the enemy is not already dying, subtracts 30 from the player's "health" variable and 
calls the "death()" function, so the enemy also dies after hitting the player.
"""
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	#Only damages the player if this enemy is not already dying (prevents repeated hits)
	if body.name == "player_character" and sprite.animation != "dead" and visible:
		#Reduces the player's health by 30. This is double the health recovered by players when picking up cherries.
		#This way, even if they pick the spawned cherry, players will lose health.
		Game.playerHP -= 30
		death()
