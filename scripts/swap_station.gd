extends Area2D

@export var new_weapon_type: int = -1

func _on_body_entered(body):
	if body.is_in_group("player"):
		swap_vehicle(body)
		queue_free()

func swap_vehicle(player):
	player.health = player.max_health
	player.shield = player.max_shield
	var type = new_weapon_type
	if type == -1:
		type = randi() % 3
	player.current_weapon = type
