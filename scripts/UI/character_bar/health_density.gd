extends ProgressBar

@onready var unit_healt_bar: float = 100
@onready var num_of_marks:int = 0
@onready var x: float = 0

func _draw() -> void:
	num_of_marks = ceil(max_value / unit_healt_bar)
	for i in range(num_of_marks - 1):
		x = (i + 1) * round(size.x * (unit_healt_bar / max_value))
		draw_line(Vector2(x, 0), Vector2(x, size.y/3), Color.BLACK, 2, true)

func _process(delta: float) -> void:
	queue_redraw()
