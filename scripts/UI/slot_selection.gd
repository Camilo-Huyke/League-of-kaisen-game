extends Panel

@export var image_texture: Texture2D
@export var character_path: String

func _ready() -> void:
	$TextureRect.texture = image_texture
	
func set_selected(boolean):
	var styleBox = get_theme_stylebox("panel").duplicate()
	
	if boolean:
		styleBox.bg_color = Color(1, 1, 1)
	else:
		styleBox.bg_color = Color(0, 0, 0)
		
	add_theme_stylebox_override("panel", styleBox)
		
