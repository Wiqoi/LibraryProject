extends RigidBody2D

var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
@export var interaction_text: String = "Picking up backpack..."
@export var interaction_duration: float = 3.5
var is_organizing: bool = false
var interaction_elapsed: float = 0.0
var is_mouse_hovering: bool = false
var done: bool = false

func _ready() -> void:
	player_node = Global.player_node
	add_to_group("interactables")

	var area = $Area2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true

func is_available() -> bool:
	return not done and not Global.player_has_backpack and not Global.is_interacting

func _process(delta: float) -> void:
	if self.linear_velocity != Vector2(0, 0):
		await get_tree().create_timer(0.1).timeout
		self.linear_velocity -= Vector2(0.1, 0.1)
		self.linear_velocity = Vector2(max(0, self.linear_velocity.x), max(0, self.linear_velocity.y))

	if is_organizing:
		interaction_elapsed += delta
		var ratio = min(interaction_elapsed / interaction_duration, 1.0)
		Global.interaction_progress.emit(ratio)
		if interaction_elapsed >= interaction_duration:
			_complete_pickup()
		return

	if not done and player_node != null and not Global.player_has_backpack:
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

	# Attach backpack to player using the sprite texture
	var sprite = $Sprite2D
	if sprite and sprite.texture:
		player_node.attach_backpack(sprite.texture)

	# Remove ObjectMarker and self
	if has_node("ObjectMarker"):
		$ObjectMarker.queue_free()
	queue_free()
