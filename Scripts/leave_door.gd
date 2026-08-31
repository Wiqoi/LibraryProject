extends Area2D

@export var interaction_text: String = "Letting kids leave..."
@export var interaction_duration: float = 1.75
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var is_mouse_hovering: bool = false
var done: bool = false
var cutscene_started: bool = false
var gate_open: bool = false

func _ready() -> void:
	add_to_group("interactables")
	input_pickable = true
	mouse_entered.connect(func(): is_mouse_hovering = true)
	mouse_exited.connect(func(): is_mouse_hovering = false)
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false

func _leave_gate_open() -> bool:
	return Global.checkout_done >= Global.checkout_total and Global.chairs_done >= Global.chairs_total and Global.lineup_done >= Global.lineup_total

func is_available() -> bool:
	return gate_open and not done and not Global.is_interacting and not Global.player_has_backpack

func _process(delta: float) -> void:
	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_interaction()
		return

	# Start the finale cutscene once the interaction completed
	if not cutscene_started and Global.firstLeave == 1:
		cutscene_started = true
		_play_cutscene()
		return

	if not cutscene_started and not done:
		if not gate_open and _leave_gate_open():
			gate_open = true
			Global.objectives_revealed[3] = true

		if has_node("ObjectMarker"):
			$ObjectMarker.visible = gate_open

		if gate_open and is_mouse_hovering and (Input.is_action_just_pressed("ui_interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and not Global.is_interacting and not Global.player_has_backpack:
			start_interaction()

func start_interaction() -> void:
	if is_organizing or done:
		return
	is_organizing = true
	interaction_elapsed = 0.0
	Global.is_interacting = true
	Global.interaction_started.emit(interaction_text)

func _complete_interaction() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	done = true
	Global.is_interacting = false
	Global.interaction_finished.emit()
	Global.task_completed.emit(global_position)

	# Block the level's auto-transition so the cutscene controls the exit
	Global.level_transitioning = true

	if Global.firstLeave == 0:
		Global.firstLeave = 1
	Global.leave_done += 1
	Global.events_done += 1
	Global.objectives_done[3] = true

	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false

func _play_cutscene() -> void:
	Global.lvl3done = 1

	# All the lined-up kids walk out toward the right
	for kid in get_tree().get_nodes_in_group("kids"):
		kid.walk_out()

	# Slow fade to black, then on to the victory screen
	# Parent the overlay to the current scene so it is freed on scene change
	var layer = CanvasLayer.new()
	layer.layer = 100
	get_tree().current_scene.add_child(layer)
	var rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	var tween = create_tween()
	tween.tween_interval(0.4)
	tween.tween_property(rect, "color:a", 1.0, 2.5)
	tween.tween_interval(0.3)
	await tween.finished
	get_tree().change_scene_to_packed(load("res://Scenes/UIFolders/VictoryScreen.tscn"))
