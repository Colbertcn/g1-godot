extends CharacterBody2D

# 移动
@export var speed: float = 300.0

# 信号
signal health_changed(current, max)
signal shield_changed(current, max)
signal level_up_triggered()

# 属性
@export var max_health: float = 100.0
@export var max_shield: float = 100.0
var health: float = max_health:
	set(value):
		health = value
		health_changed.emit(health, max_health)
var shield: float = max_shield:
	set(value):
		shield = value
		shield_changed.emit(shield, max_shield)

var level: int = 1
var xp: float = 0.0
var xp_to_next_level: float = 100.0

# 战斗
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var is_auto_firing: bool = true
var fire_rate: float = 0.2
var fire_timer: float = 0.0

# 模式
enum WeaponType { BALANCED, SPREAD, PIERCING }
@export var current_weapon: WeaponType = WeaponType.BALANCED
var weapon_mode: int = 0 # 0: Normal, 1: Focus (can be used to narrow spread)
var wingman_mode: int = 0:
	set(value):
		wingman_mode = value
		update_wingmen_positions()

# 僚机
@export var wingman_scene: PackedScene = preload("res://scenes/wingman.tscn")
var wingmen: Array[Node2D] = []

# 护盾回复
var shield_regen_interval: float = 10.0
var shield_regen_timer: float = 0.0

@onready var muzzle = $Muzzle

func _ready():
	add_to_group("player")
	health = max_health
	shield = max_shield
	health_changed.emit(health, max_health)
	shield_changed.emit(shield, max_shield)

	# 测试用：初始僚机
	add_wingman()
	add_wingman()

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

func _process(delta):
	if is_auto_firing:
		fire_timer += delta
		if fire_timer >= fire_rate:
			shoot()
			fire_timer = 0.0

	shield_regen_timer += delta
	if shield_regen_timer >= shield_regen_interval:
		regen_shield()
		shield_regen_timer = 0.0

func _input(event):
	if event.is_action_pressed("toggle_fire"):
		is_auto_firing = !is_auto_firing
	if !is_auto_firing and event.is_action_pressed("ui_accept"):
		shoot()
	if event.is_action_pressed("switch_weapon_mode"):
		# For prototype, cycle weapon types.
		# In full game, this might toggle Focused vs Spread for the current weapon.
		current_weapon = (current_weapon + 1 as WeaponType) % 3 as WeaponType
		print("Current Weapon: ", current_weapon)
	if event.is_action_pressed("switch_wingman_mode"):
		wingman_mode = (wingman_mode + 1) % 2

func shoot():
	if not bullet_scene:
		return

	match current_weapon:
		WeaponType.BALANCED:
			fire_balanced()
		WeaponType.SPREAD:
			fire_spread()
		WeaponType.PIERCING:
			fire_piercing()

func fire_balanced():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_transform = muzzle.global_transform

func fire_spread():
	var angles = [-15, 0, 15]
	for angle in angles:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_transform = muzzle.global_transform
		bullet.rotation_degrees += angle

func fire_piercing():
	var bullet = bullet_scene.instantiate()
	if bullet.has_method("set_piercing"):
		bullet.set_piercing(true)
	get_parent().add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	# Visually distinguish
	bullet.modulate = Color(0.5, 1.0, 1.0)

func add_wingman():
	if wingman_scene:
		var wm = wingman_scene.instantiate()
		get_parent().add_child.call_deferred(wm)
		wm.target = self
		wingmen.append(wm)
		update_wingmen_positions()

func update_wingmen_positions():
	for i in range(wingmen.size()):
		var wm = wingmen[i]
		var target_offset = Vector2(-40, 0)
		if wingman_mode == 0: # 集中
			target_offset.y = (i + 1) * 20 if i % 2 == 0 else -(i + 1) * 20
			target_offset.x = -40
		else: # 扩散
			target_offset.y = (i + 1) * 50 if i % 2 == 0 else -(i + 1) * 50
			target_offset.x = -60
		wm.offset = target_offset

func regen_shield():
	var amount = max_shield * 0.2
	shield = min(shield + amount, max_shield)

func take_damage(amount: float):
	if shield > 0:
		if shield >= amount:
			shield -= amount
		else:
			var remaining = amount - shield
			shield = 0
			health -= remaining
	else:
		health -= amount

	if health <= 0:
		die()

func die():
	get_tree().call_deferred("reload_current_scene")

func add_xp(amount: float):
	xp += amount
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	xp -= xp_to_next_level
	level += 1
	xp_to_next_level *= 1.2
	health = min(health + max_health * 0.2, max_health)
	shield = min(shield + max_shield * 0.2, max_shield)
	for wm in wingmen:
		if wm.has_method("restore_shield"):
			wm.restore_shield()
	level_up_triggered.emit()

func _on_upgrade_selected(choice):
	match choice:
		1: speed += 50
		2: fire_rate = max(0.05, fire_rate - 0.02)
		3: add_wingman()

func get_auto_fire():
	return is_auto_firing
