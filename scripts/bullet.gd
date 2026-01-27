extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 2.0
@export var damage: float = 10.0

var is_piercing: bool = false
var pierce_count: int = 3
var hit_objects: Array = [] # To prevent hitting the same object multiple times in one frame

func _ready():
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_timeout)

func _process(delta):
	position += transform.x * speed * delta

func set_piercing(value: bool, count: int = 3):
	is_piercing = value
	pierce_count = count

func _on_body_entered(body):
	if body in hit_objects:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		hit_objects.append(body)
		handle_collision()

func _on_area_entered(area):
	if area in hit_objects:
		return

	if area.has_method("take_damage"):
		area.take_damage(damage)
		hit_objects.append(area)
		handle_collision()

func handle_collision():
	if is_piercing and pierce_count > 0:
		pierce_count -= 1
	else:
		queue_free()

func _on_lifetime_timeout():
	queue_free()
