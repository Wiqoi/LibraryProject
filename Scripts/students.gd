extends CharacterBody2D

var player_node: CharacterBody2D = null  # Assign your Player's CharacterBody2D in the inspector
@export var interaction_range: float = 100.0  # Max distance between book and player for interaction (adjust as needed)
@export var map_min: Vector2 = Vector2(-800, -800)  # Min X/Y of your game map (spawn area)
@export var map_max: Vector2 = Vector2(800, 800)  # Max X/Y of your game map (spawn area)
var is_organizing: bool = false  # Flag to prevent multiple interactions
var animated_sprite: AnimatedSprite2D  # Reference to the AnimatedSprite2D node
var is_mouse_hovering = false

func find_player() -> void:
	# Find the player node in the scene tree (adjust the node path to match your player's name)
	player_node = Global.player_node
		
func _ready() -> void:
	find_player()
	
	animated_sprite = $StudentSprite
	
	var area = $StudentArea2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true  # Enable mouse detection
	
	randomize_spawn_position()
	
	if animated_sprite:
		play_player_idle_animation()
		# Connect animation finished signal (to detect when BookOrganize ends)
		animated_sprite.animation_finished.connect(_on_animation_finished)

func randomize_spawn_position() -> void:
	var random_x = randf_range(map_min.x, map_max.x)
	var random_y = randf_range(map_min.y, map_max.y)
	global_position = Vector2(random_x, random_y)

# Play the looping BookIdle animation
func play_player_idle_animation() -> void:
	if animated_sprite.animation != "StudentIdle":
		animated_sprite.play("StudentIdle")

# Play the one-shot BookOrganize animation (non-looping)
func play_book_organize_animation() -> void:
	if not is_organizing and animated_sprite.animation != "StudentChecked":
		is_organizing = true
		animated_sprite.stop()  # Stop idle animation first
		animated_sprite.play("StudentChecked")

# --------------------------
# Interaction Detection (Player Input + Proximity + Mouse Hover)
# --------------------------
func _process(_delta: float) -> void:
	# Skip processing if already organizing (prevent duplicate triggers)
	if is_organizing:
		return
	
	# 1. Check if book is near the player (within interaction range)
	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and Input.is_action_just_pressed("ui_interact"):
			play_book_organize_animation()

# --------------------------
# Animation Finished Callback (Self-Delete After BookOrganize)
# --------------------------
# Replace the existing method:
func _on_animation_finished() -> void:  # Remove the anim_name parameter
	# Get the current animation name from the AnimatedSprite2D
	var anim_name = animated_sprite.animation
	if anim_name == "StudentChecked":
		queue_free()
