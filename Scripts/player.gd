extends CharacterBody2D

@export var move_speed: float = 100.0
@export var sprint_speed: float = move_speed*1.5
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 20.0
@export var stamina_regen_rate: float = 15.0
@export var min_stamina_to_sprint: float = 5.0

@onready var animations: AnimatedSprite2D = $Animations

var movement_dir: Vector2 = Vector2.ZERO
var current_stamina: float = max_stamina
var is_sprinting: bool = false
var can_sprint: bool = true
var current_speed: float = move_speed
var carried_backpack: AnimatedSprite2D = null

func attach_backpack(backpack_texture: Texture2D) -> void:
	if carried_backpack:
		carried_backpack.queue_free()

	# Create SpriteFrames with one frame from the backpack texture
	var frames = SpriteFrames.new()
	frames.add_animation("carry")
	frames.set_animation_speed("carry", 5.0)
	frames.add_frame("carry", backpack_texture)

	carried_backpack = AnimatedSprite2D.new()
	carried_backpack.sprite_frames = frames
	carried_backpack.animation = "carry"
	carried_backpack.position = Vector2(0, -18)
	carried_backpack.scale = Vector2(0.4, 0.4)
	carried_backpack.z_index = 1
	add_child(carried_backpack)
	Global.player_has_backpack = true

func remove_backpack() -> void:
	if carried_backpack:
		carried_backpack.queue_free()
		carried_backpack = null
	Global.player_has_backpack = false

func _physics_process(_delta: float) -> void:
	if Global.level_transitioning:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	movement_dir = Vector2(
		Input.get_action_strength("Move_Right") - Input.get_action_strength("Move_Left") + Global.LR,
		Input.get_action_strength("Move_Down") - Input.get_action_strength("Move_Up") + Global.UD
	).normalized()
	
	velocity = movement_dir * current_speed
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * 20)
	update_animation()


func update_animation():
	var target_anim: String = "Idle"

	# Direction suffix based on movement (empty = idle)
	var suffix := "idle"
	if movement_dir != Vector2.ZERO:
		if abs(movement_dir.y) > abs(movement_dir.x):
			suffix = "up" if movement_dir.y < 0 else "down"
		else:
			suffix = "right" if movement_dir.x > 0 else "left"

	if Global.player_has_backpack:
		# Bag set: Bagidle / BagUp / BagDown / BagLeft / BagRight
		target_anim = "Bag" + (suffix if suffix == "idle" else suffix.capitalize())
	elif Global.player_has_book:
		# Book set: Bookidle / Bookup / Bookdown / Bookleft / Bookright
		target_anim = "Book" + suffix
	else:
		# Normal set: Idle / MoveUp / MoveDown / MoveLeft / MoveRight
		target_anim = "Idle" if suffix == "idle" else "Move" + suffix.capitalize()

	# Only change and play animation if it's different from current
	if animations.animation != target_anim:
		animations.animation = target_anim
		animations.play()

	# Set the correct frame based on movement
	if movement_dir != Vector2.ZERO:
		animations.speed_scale = 1.0  # Normal speed for movement
	else:
		animations.speed_scale = 0.0  # Pause on current frame for idle
func _ready():
	Global.player_node = self
	animations.animation = "Idle"
	animations.play()  # Make sure to play it
