extends Area2D

@export var speed: float = 300.0
@export var damage: float = 5.0

func _ready():
	add_to_group("enemy_bullets")

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func get_damage():
	return damage

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
