extends CharacterBody2D

# Movement speed (tweak in Inspector)
@export var move_speed: float = 100.0

# Reference to your AnimatedSprite2D (named "Animations")
@onready var animations: AnimatedSprite2D = $Animations

var movement_dir: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	# 1. Get input from your input maps
	movement_dir = Vector2(
		Input.get_action_strength("Move_Right") - Input.get_action_strength("Move_Left"),
		Input.get_action_strength("Move_Down") - Input.get_action_strength("Move_Up")
	).normalized()  # Prevent faster diagonal movement


	# 2. Apply movement (handles collision)
	velocity = movement_dir * move_speed
	move_and_slide()


	# 3. Update animation on AnimatedSprite2D
	update_animation()


func update_animation() -> void:
	# If not moving: set to Idle
	if movement_dir == Vector2.ZERO:
		if animations.animation != "Idle":
			animations.animation = "Idle"
	else:
		# Pick animation based on movement direction
		var target_anim: String
		# Prioritize vertical movement (swap to prioritize horizontal if needed)
		if abs(movement_dir.y) > abs(movement_dir.x):
			target_anim = "MoveUp" if movement_dir.y < 0 else "MoveDown"
		else:
			target_anim = "MoveRight" if movement_dir.x > 0 else "MoveLeft"
		
		# Update animation only if it's different
		if animations.animation != target_anim:
			animations.animation = target_anim


func _ready() -> void:
	# Start with Idle animation
	animations.animation = "Idle"
