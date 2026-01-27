extends Area2D

@export var xp_amount: float = 25.0
@export var attract_speed: float = 400.0
@export var attract_range: float = 200.0

var target: Node2D = null

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _process(delta):
	if target:
		var distance = global_position.distance_to(target.global_position)
		if distance < attract_range:
			var direction = (target.global_position - global_position).normalized()
			global_position += direction * attract_speed * delta

func _on_body_entered(body):
	if body.has_method("add_xp"):
		body.add_xp(xp_amount)
		queue_free()
