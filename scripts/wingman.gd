extends Node2D

enum WingmanType { ATTACK, DEFENSE }
@export var type: WingmanType = WingmanType.ATTACK

@export var target: Node2D
@export var offset: Vector2 = Vector2(-50, 0)
@export var follow_speed: float = 5.0
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
@export var fire_rate: float = 0.4

var fire_timer: float = 0.0
var shield: float = 100.0
var max_shield: float = 100.0

@onready var muzzle = $Muzzle
@onready var absorption_area = $AbsorptionArea

func _ready():
	if type == WingmanType.DEFENSE:
		max_shield = 200.0
		shield = max_shield
		if absorption_area:
			absorption_area.visible = true
			absorption_area.monitoring = true
		modulate = Color(0.4, 0.6, 1.0)
	else:
		if absorption_area:
			absorption_area.visible = false
			absorption_area.monitoring = false
		modulate = Color(1.0, 0.6, 0.4)

func _process(delta):
	if not target: return
	var target_pos = target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	if type == WingmanType.ATTACK:
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
	visible = true
	set_process(true)

func take_damage(amount: float):
	shield -= amount
	if shield <= 0:
		visible = false
		set_process(false)

func _on_absorption_area_area_entered(area):
	if type == WingmanType.DEFENSE and area.is_in_group("enemy_bullets"):
		var damage_amount = 5.0
		if area.has_method("get_damage"):
			damage_amount = area.get_damage()
		take_damage(damage_amount)
		area.queue_free()

func _on_hitbox_area_entered(area):
	if area is Enemy or area.is_in_group("enemy_bullets"):
		var damage_amount = 10.0
		if area.has_method("get_damage"):
			damage_amount = area.get_damage()
		take_damage(damage_amount)
		if area.is_in_group("enemy_bullets"):
			area.queue_free()
