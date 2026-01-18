extends State

func enter():
	if player:
		player.animation_player.play("Idle")
	
func update(_delta:float):
	pass

func update_physics(_delta:float):
	if player:
		if not player.is_on_floor():
			player.velocity += player.get_gravity() * _delta
			player.move_and_slide()
