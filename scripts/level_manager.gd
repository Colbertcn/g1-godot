extends Node2D

@export var scroll_speed: float = 100.0
@onready var camera = $Camera2D
@onready var player = $Player
@onready var spawner = get_node_or_null("Spawner")

@export var swap_station_scene: PackedScene = preload("res://scenes/swap_station.tscn")
@export var buffer_segment_interval: float = 30.0 # Every 30s
var buffer_timer: float = 0.0
var in_buffer: bool = false
var buffer_duration: float = 10.0 # Buffer lasts 10s
var current_buffer_timer: float = 0.0

func _physics_process(delta):
	camera.position.x += scroll_speed * delta
	player.position.x += scroll_speed * delta

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

	# Buffer logic
	handle_buffer_segment(delta)

func handle_buffer_segment(delta):
	if not spawner:
		spawner = get_node_or_null("Spawner")
		return

	if not in_buffer:
		buffer_timer += delta
		if buffer_timer >= buffer_segment_interval:
			start_buffer()
	else:
		current_buffer_timer += delta
		if current_buffer_timer >= buffer_duration:
			end_buffer()

func start_buffer():
	in_buffer = true
	buffer_timer = 0.0
	current_buffer_timer = 0.0
	if spawner:
		spawner.set_active(false)

	# Spawn Swap Station ahead
	if swap_station_scene:
		var station = swap_station_scene.instantiate()
		add_child.call_deferred(station)
		var camera_pos = camera.get_screen_center_position()
		station.global_position = Vector2(camera_pos.x + 600, 360)

func end_buffer():
	in_buffer = false
	if spawner:
		spawner.set_active(true)
