extends Control
# Level-entry animation, played once per level (the HUD is instanced with the
# player in every level scene):
# - the screen fades in from black
# - the objectives bar, options button, movement buttons and minimap swing in
#   from the right with a bounded, bouncy settle (same feel as the starting page).

func _ready() -> void:
	_fade_from_black()
	_swing_in_from_right($ObjectiveBar, 0.0)
	_swing_in_from_right($Button, 0.05)
	_swing_in_from_right($Minimap, 0.1)
	_swing_in_from_right($UserOnScreenControl, 0.15)


func _fade_from_black() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 1)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	var t := create_tween()
	t.tween_property(rect, "color:a", 0.0, 0.5)
	t.tween_callback(layer.queue_free)


func _swing_in_from_right(node, delay: float) -> void:
	var base: Vector2 = node.position
	node.position = base + Vector2(1300, 0)
	var t := create_tween()
	if delay > 0.0:
		t.tween_interval(delay)
	# Fast swing in with momentum, overshooting only 40 px past the base...
	t.tween_property(node, "position:x", base.x + 40.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# ...then a strong short bounce back to the base, which stays on screen.
	t.tween_property(node, "position:x", base.x, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
