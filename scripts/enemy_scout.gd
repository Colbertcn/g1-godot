extends Enemy

var time_passed: float = 0.0
@export var amplitude: float = 50.0
@export var frequency: float = 2.0

func _process(delta):
	# Move left relative to the world
	# Note: since the level manager moves the player and camera forward,
	# we want the enemy to move "backwards" faster than the scroll speed to appear moving left.
	# Or if they are static in the world, they will move left relative to the camera.

	position.x -= speed * delta

	# Sinusoidal vertical movement
	time_passed += delta
	position.y += sin(time_passed * frequency) * amplitude * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Clean up when off screen
	queue_free()
