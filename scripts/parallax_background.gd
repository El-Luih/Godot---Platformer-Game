# (ae) = Already explained in another part of the code.
#Makes the parallax background scroll continuously to the left at a constant speed.

extends ParallaxBackground

#Scrolling speed in pixels per second (see SPEED_REG in the player script).
var scrolling_speed = 70

"""
Built-in virtual function. Called once every rendered frame, not every physics tick.
The time between frames varies, so "delta" is still needed.
"""
func _process(delta):
	"""
	"scroll_offset" is a Vector2 that shifts all ParallaxLayer children, each scaled by its own "motion_scale".
	Different scales create the depth effect.
	Decreasing x moves the background to the left. "delta" keeps the speed independent of the frame rate.
	"""
	scroll_offset.x -= scrolling_speed * delta
