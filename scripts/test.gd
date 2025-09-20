extends Node
var counter = 0
var counter_2 = 0
const PLAYER = preload("res://scenes/characteres/character_ogro.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	counter += delta
	if counter >= 1:
		counter_2 +=1
		print(counter_2)
		var player: Player = PLAYER.instantiate()
		player.position.y = 21
		player.position.x = randi_range(-35, 35)
		player.position.z = randi_range(-35, 35)
		add_child(player)
		counter -= 1
