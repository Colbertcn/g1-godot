extends Node2D

@export var scroll_speed: float = 100.0
@onready var camera = $Camera2D
@onready var player = $Player

func _physics_process(delta):
	# Move the camera forward
	camera.position.x += scroll_speed * delta

	# Move player with camera
	player.position.x += scroll_speed * delta

	# Clamp player within camera view
	var viewport_rect = get_viewport_rect()
	var camera_pos = camera.get_screen_center_position()
	var half_width = (viewport_rect.size.x / camera.zoom.x) / 2
	var half_height = (viewport_rect.size.y / camera.zoom.y) / 2

	var min_x = camera_pos.x - half_width + 30
	var max_x = camera_pos.x + half_width - 30
	var min_y = camera_pos.y - half_height + 30
	var max_y = camera_pos.y + half_height - 30

	player.position.x = clamp(player.position.x, min_x, max_x)
	player.position.y = clamp(player.position.y, min_y, max_y)
