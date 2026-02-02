extends CharacterBody2D

@export var move_speed: float = 100.0
@export var sprint_speed: float = 200.0
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 20.0
@export var stamina_regen_rate: float = 15.0
@export var min_stamina_to_sprint: float = 5.0

@onready var animations: AnimatedSprite2D = $Animations
@onready var stamina_bar: ProgressBar = $CanvasLayer/Hud/ProgressBar

var movement_dir: Vector2 = Vector2.ZERO
var current_stamina: float = max_stamina
var is_sprinting: bool = false
var can_sprint: bool = true
var current_speed: float = move_speed

func _physics_process(delta: float) -> void:
	movement_dir = Vector2(
		Input.get_action_strength("Move_Right") - Input.get_action_strength("Move_Left"),
		Input.get_action_strength("Move_Down") - Input.get_action_strength("Move_Up")
	).normalized()
	
	handle_sprint_input()
	update_stamina(delta)
	update_speed()
	
	velocity = movement_dir * current_speed
	move_and_slide()
	
	update_animation()

func handle_sprint_input():
	if Input.is_action_pressed("Sprint") and can_sprint and movement_dir != Vector2.ZERO:
		is_sprinting = true
	else:
		is_sprinting = false

func update_stamina(delta):
	if is_sprinting and movement_dir != Vector2.ZERO:
		current_stamina -= stamina_drain_rate * delta
		if current_stamina <= 0:
			current_stamina = 0
			can_sprint = false
			is_sprinting = false
	else:
		current_stamina += stamina_regen_rate * delta
		if current_stamina >= max_stamina:
			current_stamina = max_stamina
		if current_stamina >= min_stamina_to_sprint:
			can_sprint = true
	
	stamina_bar.value = current_stamina

func update_speed():
	if is_sprinting and can_sprint and current_stamina > 0:
		current_speed = sprint_speed
	else:
		current_speed = move_speed

func update_animation():
	if movement_dir == Vector2.ZERO:
		if animations.animation != "Idle":
			animations.animation = "Idle"
	else:
		var target_anim: String
		if abs(movement_dir.y) > abs(movement_dir.x):
			target_anim = "MoveUp" if movement_dir.y < 0 else "MoveDown"
		else:
			target_anim = "MoveRight" if movement_dir.x > 0 else "MoveLeft"
		
		if animations.animation != target_anim:
			animations.animation = target_anim

func _ready():
	Global.player_node = self
	animations.animation = "Idle"
	current_stamina = max_stamina
	stamina_bar.value = current_stamina
	
