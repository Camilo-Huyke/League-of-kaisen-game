extends Camera3D

@onready var y_pos: float = 71.4
@onready var z_pos: float = 48
@onready var change_rate: float = 1.05

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position.z *= change_rate
			position.y *= change_rate
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position.z /= change_rate
			position.y /= change_rate
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			position.z = z_pos
			position.y = y_pos
