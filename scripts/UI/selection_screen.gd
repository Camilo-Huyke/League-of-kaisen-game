extends Control

@onready var character_selection_box = $VBoxContainer/HBoxContainer
@onready var playerCharPath: String

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var charNode = _get_char_node()
		
		if charNode:
			_set_char_selected(charNode)
		
func _get_char_node():
	var mouse_position = get_local_mouse_position()
	
	for node in character_selection_box.get_children():
		if node.get_global_rect().has_point(mouse_position):
			return node
			
func _set_char_selected(_charNode):
	playerCharPath = _charNode.character_path
	for node in character_selection_box.get_children():
		var isSelected = _charNode == node
		node.set_selected(isSelected)
	
func _on_start_button_pressed() -> void:
	if playerCharPath:
		GameManager.register_character.rpc_id(1, playerCharPath)
