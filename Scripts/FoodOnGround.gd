extends CharacterBody2D

var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
@export var interaction_text: String = "Cleaning up food..."
@export var interaction_duration: float = 1.75
@export var map_min: Vector2 = Vector2(-800, -800)
@export var map_max: Vector2 = Vector2(800, 800)
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var animated_sprite: AnimatedSprite2D
var is_mouse_hovering = false

func find_player() -> void:
	player_node = Global.player_node

func _ready() -> void:
	find_player()
	add_to_group("interactables")

	animated_sprite = $AnimatedSprite2D

	var area = $Area2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true

	if animated_sprite:
		play_book_idle_animation()

func randomize_spawn_position() -> void:
	if Global.bookdropcoords.size() > 0:
		global_position = Global.bookdropcoords.pick_random()
	print(global_position)
	if global_position in Global.bookdropcoords:
		print("yay")

func play_book_idle_animation() -> void:
	if animated_sprite.animation != "BookIdle":
		animated_sprite.play("BookIdle")

func is_available() -> bool:
	return not is_organizing and not Global.player_has_backpack and not Global.player_has_book and not Global.is_interacting

func _process(delta: float) -> void:
	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_interaction()
		return

	# Hide marker and block interaction while carrying a backpack or a book
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = not Global.player_has_backpack and not Global.player_has_book

	if Global.player_has_backpack or Global.player_has_book:
		return

	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and (Input.is_action_just_pressed("ui_interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and not Global.is_interacting:
			start_interaction()

func start_interaction() -> void:
	if is_organizing:
		return
	is_organizing = true
	interaction_elapsed = 0.0
	Global.is_interacting = true

	Global.events_done += 1
	Global.score += 1
	if Global.score < 0:
		Global.score = 0
	print("Food cleaned!")

	Global.interaction_started.emit(interaction_text)

func _complete_interaction() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	Global.is_interacting = false
	Global.first_food = 1
	Global.interaction_finished.emit()
	Global.task_completed.emit(global_position)

	Global.food_done += 1
	if Global.food_done >= Global.food_total:
		Global.objectives_done[3] = true
	queue_free()
