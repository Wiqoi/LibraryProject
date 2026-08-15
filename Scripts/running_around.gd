extends "res://Scripts/hand_ss.gd"

# Patrol path: starts at A (spawn), walks straight to each point in order,
# then walks back through the points in reverse, forever (A -> B -> C -> B -> A ...).
# Points are relative to the kid's spawn position. Edit per instance in the scene.
@export var run_waypoints: Array = [Vector2(0, 0), Vector2(60, 0), Vector2(120, 0)]
@export var run_speed: float = 105.0

var run_start_pos: Vector2
var run_waypoint_idx: int = 0
var run_direction: int = 1

func _ready() -> void:
	super._ready()
	interaction_text = "Stopping the running..."
	run_start_pos = global_position
	freeze = true

func _process(delta: float) -> void:
	_update_run(delta)
	super._process(delta)

func _update_run(delta: float) -> void:
	# Stop running only while THIS kid is being interacted with, is done, or in the finale
	if done != 0 or is_organizing or is_walking_away or Global.player_has_backpack:
		if animated_sprite and animated_sprite.animation == "Walk":
			animated_sprite.play("Idle")
		return

	if run_waypoints.size() < 2:
		return

	var target = run_start_pos + run_waypoints[run_waypoint_idx]
	var to_target = target - global_position
	if to_target.length() < 6.0:
		# Arrived: advance along the path, bouncing back at the ends
		run_waypoint_idx += run_direction
		if run_waypoint_idx >= run_waypoints.size():
			run_waypoint_idx = run_waypoints.size() - 2
			run_direction = -1
		elif run_waypoint_idx < 0:
			run_waypoint_idx = 1
			run_direction = 1
		return

	global_position += to_target.normalized() * run_speed * delta

	if animated_sprite and animated_sprite.animation != "Walk":
		animated_sprite.play("Walk")

func firsttime():
	Global.firstRunning = 1
	Global.events_done += 1
	Global.running_done += 1
	if Global.running_done >= Global.running_total:
		Global.objectives_done[2] = true
