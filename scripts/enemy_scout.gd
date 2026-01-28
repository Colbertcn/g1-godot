extends Enemy

var time_passed: float = 0.0
@export var amplitude: float = 50.0
@export var frequency: float = 2.0
@export var fire_rate: float = 2.0
var fire_timer: float = 0.0
@export var enemy_bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")

func _process(delta):
	position.x -= speed * delta
	time_passed += delta
	position.y += sin(time_passed * frequency) * amplitude * delta

	fire_timer += delta
	if fire_timer >= fire_rate:
		shoot()
		fire_timer = 0.0

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func shoot():
	if enemy_bullet_scene:
		var bullet = enemy_bullet_scene.instantiate()
		get_parent().add_child.call_deferred(bullet)
		bullet.global_position = global_position
		bullet.rotation = PI
