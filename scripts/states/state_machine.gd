extends Node

@export var initial_state: State
@export var input_player: Node

var states: Dictionary = {}
var current_state: State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_change_state)
			
	if input_player:
		input_player.change_state.connect(_on_input_player_change_state)
	
	if initial_state:
		current_state = initial_state
		initial_state.enter()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.update_physics(delta)
		
func _on_change_state(state, new_state_name: String):
	if state != current_state:
		return
		
	var new_state:State = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	new_state.enter()

func _on_input_player_change_state(new_state_name: String):
	var new_state:State = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	new_state.enter()
