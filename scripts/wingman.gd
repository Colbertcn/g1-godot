extends Node2D

@export var target: Node2D
@export var offset: Vector2 = Vector2(-50, 0)
@export var follow_speed: float = 5.0
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@export var fire_rate: float = 0.4

var fire_timer: float = 0.0
var shield: float = 100.0
var max_shield: float = 100.0

@onready var muzzle = $Muzzle

func _process(delta):
	if not target:
		return

	# Follow target with offset
	var target_pos = target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# Shooting logic (synced with auto-fire of player if desired, or independent)
	# For now, independent auto-fire if player is auto-firing
	if target.has_method("get_auto_fire") and target.get_auto_fire():
		fire_timer += delta
		if fire_timer >= fire_rate:
			shoot()
			fire_timer = 0.0

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_transform = muzzle.global_transform

func take_damage(amount: float):
	shield -= amount
	if shield <= 0:
		deactivate()

func deactivate():
	# Visual only for now or disable
	visible = false
	set_process(false)
	print("Wingman down!")

func get_auto_fire():
	if target and target.has_method("get_auto_fire"):
		return target.get_auto_fire()
	return false
