extends Node2D

@export var enemy_scenes: Array[PackedScene] = [preload("res://scenes/enemy_scout.tscn")]
@export var spawn_interval: float = 2.0
@export var spawn_distance_ahead: float = 800.0

var timer: float = 0.0
@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		spawn_enemy()
		timer = 0.0

func spawn_enemy():
	if enemy_scenes.is_empty():
		return

	var camera_pos = Vector2.ZERO
	if not camera:
		camera = get_viewport().get_camera_2d()

	if camera:
		camera_pos = camera.get_screen_center_position()

	var spawn_pos = Vector2.ZERO
	spawn_pos.x = camera_pos.x + spawn_distance_ahead
	# Random Y within viewport
	var viewport_height = get_viewport_rect().size.y
	spawn_pos.y = randf_range(50, viewport_height - 50)

	var enemy_scene = enemy_scenes.pick_random()
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_pos
