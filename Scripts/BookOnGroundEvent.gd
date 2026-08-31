extends CharacterBody2D
# Book pickup, mirroring the level-1 backpack: the player picks the book up,
# carries it to a Shelf item (shelf_item.gd), and stows it there.

var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
@export var interaction_text: String = "Picking up book..."
@export var interaction_duration: float = 1.75
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var animated_sprite: AnimatedSprite2D
var is_mouse_hovering = false
var done: bool = false

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

func play_book_idle_animation() -> void:
	if animated_sprite.animation != "BookIdle":
		animated_sprite.play("BookIdle")

func is_available() -> bool:
	return not done and not Global.player_has_book and not Global.is_interacting

func _process(delta: float) -> void:
	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_pickup()
		return

	# Hide marker and block interaction while carrying a book
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = not Global.player_has_book

	if done or Global.player_has_book:
		return

	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and (Input.is_action_just_pressed("ui_interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and not Global.is_interacting:
			start_pickup()

func start_pickup() -> void:
	if is_organizing or done:
		return
	is_organizing = true
	interaction_elapsed = 0.0
	Global.is_interacting = true

	Global.interaction_started.emit(interaction_text)

func _complete_pickup() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	done = true
	Global.is_interacting = false
	Global.interaction_finished.emit()

	# The player's own Book* animations show the carried book
	Global.player_has_book = true

	# Remove ObjectMarker and self
	if has_node("ObjectMarker"):
		$ObjectMarker.queue_free()
	queue_free()
