extends CharacterBody2D

# Reference to player's CharacterBody2D (assign in inspector or via Global singleton)
var player_node: CharacterBody2D = null  

# Max distance (pixels) for player to interact with this student NPC
@export var interaction_range: float = 100.0  

# Map boundary limits (prevents NPC from moving outside play area)
@export var map_min: Vector2 = Vector2(-800, -800)  # Minimum X/Y coordinates of playable area
@export var map_max: Vector2 = Vector2(800, 800)    # Maximum X/Y coordinates of playable area

# State flags
var is_checking: bool = false  # Prevents duplicate interaction triggers (locks interaction once started)
var is_mouse_hovering: bool = false  # Tracks if mouse is over NPC's collision area

# Animation reference (links to AnimatedSprite2D node for idle/checked animations)
var animated_sprite: AnimatedSprite2D  

# Movement system variables (slow, consistent path-following within bounds)
@export var move_speed: float = 20.0  # Slow movement speed (lower = slower; 10-30 recommended)
var target_position: Vector2  # Fixed destination NPC moves toward (no mid-path changes)
var is_moving: bool = true    # Master switch to enable/disable movement (stops after interaction)
@export var stop_threshold: float = 5.0  # How close to target before stopping (pixels)

# -----------------------------------------------------------------------------
# Core Setup & Initialization
# -----------------------------------------------------------------------------
# Find player node via Global singleton (replace with your player node path if needed)
func find_player() -> void:
	player_node = Global.player_node

# Runs once when NPC is spawned/loaded into scene
func _ready() -> void:
	find_player()  # Link player reference
	
	# Link to AnimatedSprite2D node (update node name if yours differs)
	animated_sprite = $StudentSprite
	
	# Set up mouse hover detection (requires Area2D named "StudentArea2D")
	var area = $StudentArea2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true  # Enable mouse detection on the Area2D
	
	# Spawn NPC at random position within map bounds
	randomize_spawn_position()
	
	# Initialize animation (play idle loop)
	if animated_sprite:
		animated_sprite.play("StudentIdle")
		# Connect animation finish signal to clean up after "checked" animation
		animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# Set FIRST random target (starts slow, consistent movement)
	set_new_target_position()

# Spawn NPC at random position within map boundary limits
func randomize_spawn_position() -> void:
	var random_x = randf_range(map_min.x, map_max.x)
	var random_y = randf_range(map_min.y, map_max.y)
	global_position = Vector2(random_x, random_y)

# -----------------------------------------------------------------------------
# Movement System (Consistent Path-Following to Target)
# -----------------------------------------------------------------------------
# Generate NEW random target position (ONLY when current target is reached)
func set_new_target_position() -> void:
	if not is_moving:  # Skip if movement is disabled (post-interaction)
		return
		
	# Generate random X/Y target WITHIN map limits (full map range)
	var random_x = randf_range(map_min.x, map_max.x)
	var random_y = randf_range(map_min.y, map_max.y)
	target_position = Vector2(random_x, random_y)

# Core movement logic (moves ALL THE WAY to target; no mid-path direction changes)
func handle_movement(delta: float) -> void:
	# Stop movement if NPC is being checked or movement is disabled
	if not is_moving or is_checking:
		velocity = Vector2.ZERO  # Immediately halt all movement
		return
	
	# Calculate distance to target (only change direction when CLOSE ENOUGH to target)
	var distance_to_target = global_position.distance_to(target_position)
	
	# 1. If reached target: set NEW target
	if distance_to_target <= stop_threshold:
		set_new_target_position()
	# 2. If NOT reached target: keep moving toward it (consistent path)
	else:
		# Calculate movement direction (normalized to prevent faster diagonal movement)
		var move_direction = (target_position - global_position).normalized()
		velocity = move_direction * move_speed  # Slow, steady speed
		
		# Move NPC (Godot's built-in collision handling)
		move_and_slide()
		
		# Failsafe: Lock NPC position inside map bounds (prevents out-of-bounds movement)
		clamp_position_to_map_bounds()

# Failsafe: Lock NPC position within map limits (prevents out-of-bounds movement)
func clamp_position_to_map_bounds() -> void:
	var clamped_x = clamp(global_position.x, map_min.x, map_max.x)
	var clamped_y = clamp(global_position.y, map_min.y, map_max.y)
	global_position = Vector2(clamped_x, clamped_y)

# -----------------------------------------------------------------------------
# Interaction & Animation Logic
# -----------------------------------------------------------------------------
# Play "checked" animation (non-looping) and stop movement
func play_book_organize_animation() -> void:
	# Only run if NPC isn't already being checked
	if not is_checking and animated_sprite.animation != "StudentChecked":
		is_checking = true       # Lock interaction state
		is_moving = false        # Stop all movement
		velocity = Vector2.ZERO  # Immediate halt
		
		animated_sprite.stop()               # Stop idle animation
		animated_sprite.play("StudentChecked")  # Play one-shot "checked" animation

# Main process loop (runs every frame)
func _process(delta: float) -> void:
	# Update movement first (consistent path-following)
	handle_movement(delta)
	
	# Skip interaction checks if NPC is already being processed
	if is_checking:
		return
	
	# Only check interaction if player node is valid
	if player_node != null:
		# Calculate distance between NPC and player
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		# Trigger interaction if: player is close + mouse hovers + interact input pressed
		if is_near_player and is_mouse_hovering and Input.is_action_just_pressed("ui_interact"):
			play_book_organize_animation()

# -----------------------------------------------------------------------------
# Cleanup (Delete NPC after "checked" animation finishes)
# -----------------------------------------------------------------------------
# Callback for animation finish (deletes NPC after "StudentChecked" animation)
func _on_animation_finished() -> void:
	# Get current animation name from AnimatedSprite2D
	var anim_name = animated_sprite.animation
	
	# Delete NPC if "checked" animation completed
	if anim_name == "StudentChecked":
		queue_free()  # Safely remove NPC from scene
