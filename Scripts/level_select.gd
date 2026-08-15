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

	# Swing the title and buttons in from the top, slightly staggered.
	_swing_in_from_top($TitleLabel, 0.0)
	_swing_in_from_top($Lvl1, 0.05)
	_swing_in_from_top($Lvl2, 0.10)
	_swing_in_from_top($Lvl3, 0.15)
	_swing_in_from_top($BackButton, 0.20)

	# Grey out levels the player cannot enter yet
	$Lvl2.disabled = Global.lvl1done == 0
	$Lvl3.disabled = Global.lvl2done == 0


func _swing_in_from_top(node: Control, delay: float) -> void:
	var base: Vector2 = node.position
	node.position = base + Vector2(0, -700)
	var t := create_tween()
	if delay > 0.0:
		t.tween_interval(delay)
	# Fast drop in with momentum, overshooting only 40 px past the base...
	t.tween_property(node, "position:y", base.y + 40.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# ...then a strong short bounce back to the base, which stays on screen.
	t.tween_property(node, "position:y", base.y, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
