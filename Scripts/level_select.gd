extends Control

func _ready() -> void:
	# Clear any leftover cutscene state so movement works in the next level
	Global.level_transitioning = false

	# Fade in from black when entering the level select screen
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 1)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	var tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.8)
	tween.finished.connect(func(): layer.queue_free())
