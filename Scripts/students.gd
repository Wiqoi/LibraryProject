extends CharacterBody2D
var player_node: CharacterBody2D = null  
var animated_sprite: AnimatedSprite2D  
@export var move_speed: float = 30.0
var target: Vector2
@onready var agent = $NavigationAgent2D

func find_player() -> void:
	player_node = Global.player_node

func _ready() -> void:
	animated_sprite = $StudentSprite
	randomize_spawn_position()
	randomize_target_position()
	if animated_sprite:
		animated_sprite.play("StudentIdle")

func randomize_spawn_position() -> void:
	if Global.studentspawnarea.size() > 0:
		global_position = Global.studentspawnarea.pick_random()

func randomize_target_position() -> void:
	if Global.studentspawnarea.size() > 0:
		target = Global.studentspawnarea.pick_random()
		updateTargetPosition(target)

func updateTargetPosition(target):
	agent.set_target_position(target)

func _process(delta: float) -> void:
	if position.distance_to(target) > 0.5:
		var curLoc = global_transform.origin
		var nextLoc = agent.get_next_path_position()
		var newVel = (nextLoc - curLoc).normalized() * move_speed
		velocity = newVel
		move_and_slide()
	else:
		randomize_target_position()
