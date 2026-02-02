extends CharacterBody2D
var player_node: CharacterBody2D = null  
var animated_sprite: AnimatedSprite2D  
@export var move_speed: float = 50.0
var target: Vector2
@onready var agent = $NavigationAgent2D
var student_counter = 0;
# Add these variables for stuck detection
var last_position: Vector2 = Vector2.ZERO
var stuck_timer: float = 0.0
var is_stuck_check_enabled: bool = true
const STUCK_THRESHOLD: float = 10.0  # Pixels movement considered "not stuck"
const STUCK_TIME_LIMIT: float = 5  # Seconds before getting new target

func find_player() -> void:
	player_node = Global.player_node

func _ready() -> void:
	print(Global.student_count)
	if Global.student_count < 20:
		Global.student_count = Global.student_count + 1
		animated_sprite = $StudentSprite
		randomize_spawn_position()
		randomize_target_position()
		if animated_sprite:
			animated_sprite.play("StudentIdle")
		# Initialize stuck detection
		last_position = global_position
	
func randomize_spawn_position() -> void:
	if Global.studentspawnarea.size() > 0:
		global_position = Global.studentspawnarea.pick_random()
		last_position = global_position

func randomize_target_position() -> void:
	if Global.studentspawnarea.size() > 0:
		target = Global.studentspawnarea.pick_random()
		# Optional: Ensure new target is different from current position
		while target.distance_to(global_position) < 50.0:
			target = Global.studentspawnarea.pick_random()
		
		updateTargetPosition(target)
		# Reset stuck timer when getting new target
		reset_stuck_timer()

func updateTargetPosition(target_position: Vector2) -> void:
	agent.set_target_position(target_position)
	reset_stuck_timer()

func reset_stuck_timer() -> void:
	stuck_timer = 0.0
	last_position = global_position

func check_if_stuck(delta: float) -> bool:
	# Update timer if we haven't moved much
	if global_position.distance_to(last_position) < STUCK_THRESHOLD:
		stuck_timer += delta
	else:
		# We've moved enough, reset the timer
		reset_stuck_timer()
	
	# Check if stuck for too long
	if stuck_timer >= STUCK_TIME_LIMIT:
		return true
	return false

func _process(delta: float) -> void:
	# First check if agent is stuck
	if is_stuck_check_enabled and check_if_stuck(delta):
		print("Student stuck for ", stuck_timer, " seconds. Getting new target.")
		randomize_target_position()
		return
	
	if position.distance_to(target) > 1:
		var curLoc = global_transform.origin
		var nextLoc = agent.get_next_path_position()
		var newVel = (nextLoc - curLoc).normalized() * move_speed
		velocity = newVel
		move_and_slide()
		
		if animated_sprite and velocity.length() > 0.1:
			# animated_sprite.play("StudentWalk")
			if velocity.x != 0:
				animated_sprite.flip_h = velocity.x < 0
		elif animated_sprite:
			animated_sprite.play("StudentIdle")
	else:
		randomize_target_position()


func force_new_target() -> void:
	randomize_target_position()
