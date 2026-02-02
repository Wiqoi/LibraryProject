extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)
@export var max_zoom: Vector2 = Vector2(2.0, 2.0)

func _process(_delta: float) -> void:
	var scroll_delta = 0.0
	if Input.is_action_just_pressed("scroll_down"):
		scroll_delta = 1.0
	elif Input.is_action_just_pressed("scroll_up"):
		scroll_delta = -1.0
	if scroll_delta != 0.0:
		adjust_camera_zoom(scroll_delta)

func adjust_camera_zoom(scroll_input: float) -> void:
	var new_zoom = zoom - (Vector2.ONE * scroll_input * zoom_speed)
	new_zoom.x = clamp(new_zoom.x, min_zoom.x, max_zoom.x)
	new_zoom.y = clamp(new_zoom.y, min_zoom.y, max_zoom.y)
	zoom = new_zoom
