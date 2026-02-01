extends CharacterBody2D
var player_node: CharacterBody2D = null  
var animated_sprite: AnimatedSprite2D  
@export var move_speed: float = 30.0
var target: Vector2
@onready var agent = $NavigationAgent2D
var Asg = AStarGrid2D.new()
var current_path: PackedVector2Array = []
var path_index: int = 0
var global_cell_position: Vector2i
var target_cell: Vector2i

func find_player() -> void:
	player_node = Global.player_node

func _ready() -> void:
	Asg.region = Rect2i(-97, -22, 97+86, 72+22)
	Asg.cell_size = Vector2i(16, 16)
	Asg.update()
	for cells in Global.studentPathFinding:
		Asg.set_point_solid(cells, true)
	animated_sprite = $StudentSprite
	randomize_spawn_position()
	randomize_target_position()
	if animated_sprite:
		animated_sprite.play("StudentIdle")

func randomize_spawn_position() -> void:
	if Global.studentspawnarea.size() > 0:
		var random_index = randi_range(0, Global.studentspawnarea.size() - 1)
		global_position = Global.studentspawnarea[random_index]
		global_cell_position = Global.studentspawnareacells[random_index]
		print(Global.studentspawnareacells[random_index])

func randomize_target_position() -> void:
	if Global.studentspawnarea.size() > 0:
		var random_index = randi_range(0, Global.studentspawnarea.size() - 1)
		target = Global.studentspawnarea[random_index]
		target_cell = Global.studentspawnareacells[random_index]
		print(Global.studentspawnareacells[random_index])
		calculate_path_to_target()

func calculate_path_to_target():
	
	current_path = Asg.get_point_path(global_cell_position, target_cell)
	path_index = 0

func updateTargetPosition(new_target):
	target = new_target
	calculate_path_to_target()

func _process(delta: float) -> void:
	if current_path.size() == 0:
		return
	
	if path_index >= current_path.size():
		randomize_target_position()
		return
	
	var current_target_world = Vector2(current_path[path_index]) * 16 + Vector2(8, 8)
	
	if global_position.distance_to(current_target_world) > 0.5:
		var direction = (current_target_world - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
	else:
		path_index += 1
		if path_index >= current_path.size():
			randomize_target_position()
