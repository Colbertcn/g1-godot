extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 2.0

func _ready():
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_timeout)

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(10.0)
	queue_free()

func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(10.0)
	queue_free()

func _on_lifetime_timeout():
	queue_free()
