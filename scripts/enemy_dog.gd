extends Enemy

func _ready():
	super._ready()
	speed = 250.0
	health = 10.0
	xp_value = 15.0

func _process(delta):
	position.x -= speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
