extends CanvasLayer

@onready var health_bar = $Control/VBoxContainer/HealthBar
@onready var shield_bar = $Control/VBoxContainer/ShieldBar

func _on_player_health_changed(current, max_val):
	health_bar.max_value = max_val
	health_bar.value = current

func _on_player_shield_changed(current, max_val):
	shield_bar.max_value = max_val
	shield_bar.value = current
