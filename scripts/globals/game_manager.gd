extends Node

var player_info = {}
var level: Node3D = null

enum state {LOBY, SELECTION, START}
var current_state: state
var prev_state: state

func _ready() -> void:
	change_state(state.LOBY)

func register_level(_level: Node3D):
	if not multiplayer.is_server():
		return
	level = _level
	#for i in player_info.keys():
		#level.add_child(player_info[i], true)
		
func register_player(id):
	if not multiplayer.is_server() and not current_state == state.SELECTION:
		return
	player_info[id] = null
	
@rpc("any_peer", "call_local", "reliable")
func register_character(playerCharPath):
	if not multiplayer.is_server() and not current_state == state.SELECTION:
		return
	var _character = load(playerCharPath)
	if _character:
		var character = _character.instantiate()
		character.name = str(multiplayer.get_remote_sender_id())
		player_info[multiplayer.get_remote_sender_id()] = character
		
#State machibe
func change_state(new_state: state):
	exit_state(current_state)
	
	prev_state = current_state
	current_state = new_state
	
	enter_state(new_state)
	
func exit_state(_state: state):
	match _state:
		state.LOBY:
			pass
		state.SELECTION:
			pass
		state.START:
			pass
	
func enter_state(_state: state):
	match _state:
		state.LOBY:
			pass
		state.SELECTION:
			selection_state()
		state.START:
			pass
			
func update_state(delta):
	match current_state:
		state.LOBY:
			pass
		state.SELECTION:
			pass
		state.START:
			pass
#states
func selection_state():
	if not multiplayer.is_server():
		return
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.wait_time = 7
	timer.one_shot = true
	timer.timeout.connect(init_level)
	timer.start()

#Start level
func init_level():
	init_level_remote.rpc()

@rpc("authority", "call_local", "reliable")
func init_level_remote():
	change_state(state.START)
	get_tree().change_scene_to_file("res://scenes/Level.tscn")
