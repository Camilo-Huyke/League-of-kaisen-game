extends Control

@export var parent: Node3D
@export var parent_hitbox: CollisionShape3D

@onready var timer = $Timer
@onready var health_bar = $Health
@onready var damage_bar = $Damage
@onready var value_text = $Health/Label

var health: int = 0
var prev_health: int = 0

func _process(delta: float) -> void:
	if parent:
		position = get_viewport().get_camera_3d().unproject_position(parent.global_position + Vector3(0, parent_hitbox.shape.height * 1.4, 0)) + Vector2(-health_bar.size.x/2, 0)

func set_max_health():
	health_bar.max_value = health
	damage_bar.max_value = health
	
func set_health(new_health):
	prev_health = health
	health = min(health_bar.max_value, new_health)
	health_bar.value = health
	
	if health <= 0:
		queue_free()
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health
	
	value_text.text = str(health)
	
	"""if health < health_bar.max_value:
		health_bar.get_theme_stylebox('fill').border_width_right = 0
	elif health == health_bar.max_value:
		health_bar.get_theme_stylebox('fill').border_width_right = 2"""
	
func init_health(_health):
	health = _health
	
	health_bar.max_value = health
	damage_bar.max_value = health
	
	health_bar.value = health
	damage_bar.value = health
	
	value_text.text = str(health)
	
func _on_timer_timeout() -> void:
	damage_bar.value = health
