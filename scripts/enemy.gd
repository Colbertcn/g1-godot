extends Area2D

class_name Enemy

signal died(xp_amount)

@export var health: float = 20.0
@export var speed: float = 150.0
@export var damage: float = 10.0
@export var xp_value: float = 25.0
@export var xp_gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func die():
	died.emit(xp_value)
	spawn_xp()
	queue_free()

func spawn_xp():
	if xp_gem_scene:
		var gem = xp_gem_scene.instantiate()
		gem.xp_amount = xp_value
		get_parent().add_child.call_deferred(gem)
		gem.global_position = global_position

func _on_area_entered(_area):
	pass

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		die()
