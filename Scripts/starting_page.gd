extends Control
# Starting page: the title and buttons swing in from the left on entry, and
# swing back out to the left while the screen fades to black on exit
# (the level select screen then fades back in).

var _exiting: bool = false


func _ready() -> void:
	# Title first, then the buttons, slightly staggered.
	_swing_in_from_left($Title, 0.0)
	_swing_in_from_left($VBoxContainer, 0.15)


func _swing_in_from_left(node: Control, delay: float) -> void:
	var base := node.position
	node.position = base + Vector2(-1600, 0)
	var t := create_tween()
	if delay > 0.0:
		t.tween_interval(delay)
	# Fast swing in with momentum, overshooting only 70 px past the base...
	t.tween_property(node, "position:x", base.x + 70.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# ...then a strong short bounce back to the base, which never leaves the screen.
	t.tween_property(node, "position:x", base.x, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func play_exit() -> void:
	# Swing the title and buttons off to the right while fading to black.
	# Called by the menu buttons (start.gd / quit.gd) before they act.
	if _exiting:
		return
	_exiting = true

	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	# One tween, one await: swing-out and fade run together with equal durations.
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property($Title, "position", $Title.position + Vector2(-1600, 0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property($VBoxContainer, "position", $VBoxContainer.position + Vector2(-1600, 0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(rect, "color:a", 1.0, 0.5)
	await t.finished
