extends Node3D

@onready var spawn_points = $Spawn_points

@onready var spawn_points_list = []
@onready var spawn_counter: int = 0

var send_time = 0

func _ready() -> void:
	if not multiplayer.is_server():
		return
	for i in spawn_points.get_children(): #Añadir los puntos de spawn a la lista spawn_points_list
		spawn_points_list.append([i, false])
	set_player_position()

func set_player_position():
	for i in GameManager.player_info.keys(): #Asignar a cada jugador una posicion de los spawn points 
		if spawn_points_list[spawn_counter][1] == false:
			GameManager.player_info[i].position = spawn_points_list[spawn_counter][0].position
			spawn_points_list[spawn_counter][1] = true
			add_child(GameManager.player_info[i], true)
		spawn_counter += 1
	spawn_counter = 0
	
@rpc("any_peer", "call_local")
func ping():
	rpc_id(multiplayer.get_remote_sender_id(), "pong")
@rpc("authority", "call_local")
func pong():
	var rrt = Time.get_ticks_msec() - send_time
	$CanvasLayer/Control/Label2.text = "ms: " + str(rrt / 2)

func _on_timer_timeout() -> void:
	send_time = Time.get_ticks_msec()
	rpc_id(1, "ping")
	#print(GameManager.player_info)
