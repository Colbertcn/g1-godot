extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 2.0

func _ready():
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_timeout)

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(_body):
	# Bullet hits something
	queue_free()

func _on_lifetime_timeout():
	queue_free()
