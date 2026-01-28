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
	if not target: return
	var target_pos = target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)

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

func restore_shield():
	shield = max_shield

func take_damage(amount: float):
	shield -= amount
	if shield <= 0:
		visible = false
		set_process(false)
