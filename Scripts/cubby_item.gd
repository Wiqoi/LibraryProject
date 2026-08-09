extends Area2D

@export var interaction_text: String = "Stowing backpack..."
@export var interaction_duration: float = 3.5
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var is_mouse_hovering: bool = false
var done: bool = false

func _ready() -> void:
	input_pickable = true
	mouse_entered.connect(func(): is_mouse_hovering = true)
	mouse_exited.connect(func(): is_mouse_hovering = false)

	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("Default")

func _process(delta: float) -> void:
	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_stow()
		return

	# Only show marker and allow interaction when player has a backpack
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = Global.player_has_backpack and not done

	if not done and Global.player_has_backpack:
		if is_mouse_hovering and Input.is_action_just_pressed("ui_interact"):
			start_stow()

func start_stow() -> void:
	if is_organizing or done:
		return
	is_organizing = true
	interaction_elapsed = 0.0
	Global.interaction_started.emit(interaction_text)

func _complete_stow() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	done = true
	Global.interaction_finished.emit()

	# Remove backpack from player
	var player = Global.player_node
	if player and player.has_method("remove_backpack"):
		player.remove_backpack()

	# Complete the objective
	if Global.firstBackpack == 0:
		Global.firstBackpack = 1
	Global.events_done += 1
	Global.task_completed.emit(global_position)

	# Hide marker and switch to filled animation
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("Bag inside")
