extends Sprite2D

@onready var timer: Timer = $Timer
@onready var health_bar: ProgressBar = $ProgressBar
@onready var damage_bar: ProgressBar = $DamageBar

var health: int

func set_health(new_health):
	var prev_health = health
	health = min(health_bar.max_value, new_health)
	health_bar.value = health
	
	if health < prev_health:
		timer.start()	
	else:
		damage_bar.value = health
		
func init_health(_health):
	health = _health
	health_bar.max_value = health
	health_bar.value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _on_timer_timeout() -> void:
	damage_bar.value = health
