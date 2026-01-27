extends CharacterBody2D

# Movement
@export var speed: float = 300.0

# Signals
signal health_changed(current, max)
signal shield_changed(current, max)
signal level_up_triggered()

# Stats
@export var max_health: float = 100.0
@export var max_shield: float = 100.0
var level: int = 1
var xp: float = 0.0
var xp_to_next_level: float = 100.0
var health: float = max_health:
	set(value):
		health = value
		health_changed.emit(health, max_health)
var shield: float = max_shield:
	set(value):
		shield = value
		shield_changed.emit(shield, max_shield)

# Combat
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var is_auto_firing: bool = true
var fire_rate: float = 0.2 # Seconds between shots
var fire_timer: float = 0.0

# Modes
var weapon_mode: int = 0 # 0: Normal, 1: Alternated (to be implemented)
var wingman_mode: int = 0: # 0: Concentrated, 1: Spread
	set(value):
		wingman_mode = value
		update_wingmen_positions()

# Wingmen
@export var wingman_scene: PackedScene = preload("res://scenes/wingman.tscn")
var wingmen: Array[Node2D] = []

# Shield Regen
var shield_regen_interval: float = 10.0
var shield_regen_timer: float = 0.0

@onready var muzzle = $Muzzle

func _ready():
	health = max_health
	shield = max_shield
	health_changed.emit(health, max_health)
	shield_changed.emit(shield, max_shield)

	# Initial wingmen for testing
	add_wingman()
	add_wingman()

func _physics_process(delta):
	# 8-way movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

	# Keep player within screen boundaries (handled by camera/level manager later)
	# For now, just movement.

func _process(delta):
	# Auto-firing logic
	if is_auto_firing:
		fire_timer += delta
		if fire_timer >= fire_rate:
			shoot()
			fire_timer = 0.0

	# Shield Regeneration
	shield_regen_timer += delta
	if shield_regen_timer >= shield_regen_interval:
		regen_shield()
		shield_regen_timer = 0.0

func _input(event):
	# Toggle Auto-fire
	if event.is_action_pressed("toggle_fire"): # Needs mapping in project.godot or handle manually
		is_auto_firing = !is_auto_firing

	# Manual shoot
	if !is_auto_firing and event.is_action_pressed("ui_accept"):
		shoot()

	# Switch Weapon Mode
	if event.is_action_pressed("switch_weapon_mode"):
		weapon_mode = (weapon_mode + 1) % 2
		print("Weapon Mode: ", weapon_mode)

	# Switch Wingman Mode
	if event.is_action_pressed("switch_wingman_mode"):
		wingman_mode = (wingman_mode + 1) % 2
		print("Wingman Mode: ", wingman_mode)

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_transform = muzzle.global_transform

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
		if wingman_mode == 0: # Concentrated
			target_offset.y = (i + 1) * 20 if i % 2 == 0 else -(i + 1) * 20
			target_offset.x = -40
		else: # Spread
			target_offset.y = (i + 1) * 50 if i % 2 == 0 else -(i + 1) * 50
			target_offset.x = -60

		wm.offset = target_offset

func regen_shield():
	var amount = max_shield * 0.2
	shield = min(shield + amount, max_shield)
	print("Shield Regened: ", shield)

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
	# Game Over logic
	print("Player Died!")
	get_tree().reload_current_scene()

func get_auto_fire():
	return is_auto_firing

func add_xp(amount: float):
	xp += amount
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	xp -= xp_to_next_level
	level += 1
	xp_to_next_level *= 1.2
	print("Level Up! Level: ", level)

	# Restore shield/health according to rules
	health = min(health + max_health * 0.2, max_health)
	# "升级时恢复20%" for host shield.
	shield = min(shield + max_shield * 0.2, max_shield)

	# Restore wingmen shields
	for wm in wingmen:
		wm.shield = wm.max_shield

	trigger_upgrade_choice()

func trigger_upgrade_choice():
	level_up_triggered.emit()

func _on_upgrade_selected(choice):
	match choice:
		1:
			speed += 50
			print("Upgraded Speed: ", speed)
		2:
			fire_rate = max(0.05, fire_rate - 0.02)
			print("Upgraded Fire Rate: ", fire_rate)
		3:
			add_wingman()
			print("Added Wingman. Total: ", wingmen.size())
