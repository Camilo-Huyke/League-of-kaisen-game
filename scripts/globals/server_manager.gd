extends Node
class_name Server_Manager

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 25565
const DEFAULT_SERVER_IP = "localhost"
const MAX_CONNECTIONS = 7

@onready var multiplayer_UI:Multiplayer_lobby = null #get_tree().root.get_node("multiplayer_lobby")
@onready var line_edit:LineEdit = null #get_tree().root.get_node("multiplayer_lobby/VBoxContainer/LineEdit")

var selection_screen = preload("res://scenes/selection_screen.tscn")
# This will contain player info for every player,
# with the keys being each player's unique IDs.
#var players = {}
# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
#var player_info = {"name": "Name"}
var players_loaded = 0
	
func register_UI(_multiplayer_UI, _line_edit):
	multiplayer_UI = _multiplayer_UI
	line_edit = _line_edit
	multiplayer_UI.host.pressed.connect(create_game)
	multiplayer_UI.join.pressed.connect(join_game)

func join_game(address = ""):
	if address.is_empty():
		if line_edit.text != "":
			address = line_edit.text
		else:
			address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	add_player(multiplayer.get_unique_id())
	player_connected.emit(1, GameManager.player_info)
	
	get_tree().change_scene_to_packed(selection_screen)
	GameManager.change_state(GameManager.state.SELECTION)

func add_player(pid):
	#var player = PLAYER.instantiate()
	#player.name = str(pid)
	#add_child(player, true)
	#GameManager.player_info[pid] = player
	GameManager.register_player(pid)
	players_loaded += 1

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	add_player(id)
	_register_player.rpc_id(id, GameManager.player_info)
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	player_connected.emit(new_player_id, new_player_info)
	
func _on_player_disconnected(id):
	var player: Player = GameManager.player_info[id]
	GameManager.player_info.erase(id)
	player.queue_free()
	player_disconnected.emit(id)
	print("_on_player_disconnected")

func _on_connected_ok():  
	var peer_id = multiplayer.get_unique_id()
	player_connected.emit(peer_id, GameManager.player_info)
	print("_on_connected_ok")
	get_tree().change_scene_to_packed(selection_screen)
	GameManager.change_state(GameManager.state.SELECTION)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	print("_on_connected_fail")
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
	print("_on_server_disconnected")
