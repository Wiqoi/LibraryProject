extends RigidBody2D

var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
@export var interaction_text: String = "Sanitizing hands..."
@export var interaction_duration: float = 3.5
@export var map_min: Vector2 = Vector2(-800, -800)
@export var map_max: Vector2 = Vector2(800, 800)
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var animated_sprite: AnimatedSprite2D
var is_mouse_hovering = false
var done = 0
var is_walking_away: bool = false

func firsttime():
	pass

func find_player() -> void:
	player_node = Global.player_node

func can_interact() -> bool:
	return done == 0

func marker_visible() -> bool:
	return not Global.player_has_backpack and not Global.player_has_book

func is_available() -> bool:
	return can_interact() and not Global.player_has_backpack and not Global.player_has_book and not Global.is_interacting

func _ready() -> void:
	find_player()
	add_to_group("interactables")

	animated_sprite = $StudentLook

	var area = $Area2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true

	if animated_sprite:
		play_book_idle_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(self.linear_velocity != Vector2(0,0)):
		await get_tree().create_timer(0.1).timeout
		self.linear_velocity -= Vector2(0.1,0.1)
		self.linear_velocity = Vector2(max(0, self.linear_velocity.x),max(0, self.linear_velocity.y))

	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_interaction()
		return

	# Hide marker and block interaction while carrying a backpack
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = marker_visible()

	if not can_interact() or Global.player_has_backpack or Global.player_has_book:
		return

	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and (Input.is_action_just_pressed("ui_interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and done == 0 and not Global.is_interacting:
			start_interaction()

func play_book_idle_animation() -> void:
	if animated_sprite.animation != "Idle":
		animated_sprite.play("Idle")

func start_interaction() -> void:
	if is_organizing:
		return
	is_organizing = true
	interaction_elapsed = 0.0
	Global.is_interacting = true

	Global.score += 1
	if Global.score < 0:
		Global.score = 0
	print("Interaction started!")

	Global.interaction_started.emit(interaction_text)

func _complete_interaction() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	Global.is_interacting = false
	Global.interaction_finished.emit()
	Global.task_completed.emit(global_position)

	firsttime()
	if has_node("ObjectMarker"):
		self.remove_child($ObjectMarker)
	done = 1
	if animated_sprite:
		animated_sprite.animation = "Idle"
