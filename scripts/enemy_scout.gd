extends Enemy

var time_passed: float = 0.0
@export var amplitude: float = 50.0
@export var frequency: float = 2.0

func _process(delta):
	position.x -= speed * delta
	time_passed += delta
	position.y += sin(time_passed * frequency) * amplitude * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
