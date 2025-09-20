extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = 'FPS: ' + str(Engine.get_frames_per_second())
