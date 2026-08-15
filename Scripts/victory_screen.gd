extends Control
# Victory screen shown after a level is completed. Fades in from black and the
# panel swings down from the top (same feel as the level select screen).
# The next unlocked level is highlighted and can be started straight away.

func _ready() -> void:
	var next_level := 0
	if Global.lvl1done == 1 and Global.lvl2done == 0:
		next_level = 2
	elif Global.lvl2done == 1 and Global.lvl3done == 0:
		next_level = 3

	var next_btn := $Panel/VBoxContainer/NextLevelButton
	if next_level > 0:
		next_btn.text = "Next Level: Level " + str(next_level)
		next_btn.pressed.connect(_on_next_pressed.bind(next_level))
	else:
		next_btn.visible = false
		if Global.lvl3done == 1:
			$Panel/VBoxContainer/MessageLabel.text = "You finished all levels!"

	$Panel/VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)

	_fade_from_black()
	_swing_in_from_top($Panel)


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
	t.tween_property(rect, "color:a", 0.0, 0.8)
	t.tween_callback(layer.queue_free)


func _swing_in_from_top(node: Control) -> void:
	var base: Vector2 = node.position
	node.position = base + Vector2(0, -700)
	var t := create_tween()
	# Fast drop in with momentum, overshooting only 40 px past the base...
	t.tween_property(node, "position:y", base.y + 40.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# ...then a strong short bounce back to the base, which stays on screen.
	t.tween_property(node, "position:y", base.y, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _on_next_pressed(level: int) -> void:
	get_tree().change_scene_to_packed(load("res://Scenes/level%d.tscn" % level))


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://Scenes/UIFolders/LevelSelect.tscn"))
