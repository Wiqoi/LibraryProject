extends Area2D
# Shelf item, mirroring the level-1 cubby: only interactable while the player
# carries a book. Stowing the book completes the book event and triggers the
# book rule quiz on the first placement.

@export var interaction_text: String = "Shelving book..."
@export var interaction_duration: float = 1.75
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var is_mouse_hovering: bool = false
var done: bool = false

func _ready() -> void:
	add_to_group("interactables")
	input_pickable = true
	mouse_entered.connect(func(): is_mouse_hovering = true)
	mouse_exited.connect(func(): is_mouse_hovering = false)

	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false
	$AnimatedSprite2D.play("NoBook")

func is_available() -> bool:
	return not done and Global.player_has_book and not Global.is_interacting

func _process(delta: float) -> void:
	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_stow()
		return

	# Only show marker and allow interaction when the player carries a book
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = Global.player_has_book and not done

	if not done and Global.player_has_book:
		if is_mouse_hovering and (Input.is_action_just_pressed("ui_interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and not Global.is_interacting:
			start_stow()

func start_stow() -> void:
	if is_organizing or done:
		return
	is_organizing = true
	interaction_elapsed = 0.0
	Global.is_interacting = true
	Global.interaction_started.emit(interaction_text)

func _complete_stow() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	done = true
	Global.is_interacting = false
	Global.interaction_finished.emit()

	# Clear the carried-book state (the player's Book* animations switch back)
	Global.player_has_book = false

	# Complete the book objective; the first placement triggers the rule quiz
	if Global.firstBook == 0:
		Global.firstBook = 1
	Global.events_done += 1
	Global.books_done += 1
	if Global.books_done >= Global.books_total:
		Global.objectives_done[0] = true
	Global.task_completed.emit(global_position)

	# Hide marker and switch the shelf to its filled state
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false
	$AnimatedSprite2D.play("HasBook")
