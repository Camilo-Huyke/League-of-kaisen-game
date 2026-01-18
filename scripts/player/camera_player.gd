extends Camera3D

@onready var proportion: float = 1.4825
@onready var z_pos: float = 60
@onready var y_pos: float = z_pos * proportion
@onready var change_rate: float = 1.0

func _ready() -> void:
	position.y = y_pos
	position.z = z_pos
	rotation.x = deg_to_rad(-56)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and position.z < z_pos and position.y < y_pos:
			position.z += change_rate
			position.y = position.z * proportion
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and position.z > 5 and position.y > 5:
			position.z -= change_rate
			position.y = position.z * proportion
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			position.z = z_pos
			position.y = y_pos
