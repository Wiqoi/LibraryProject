extends Node

@export var chair_scene: PackedScene
@export var min_spawn_delay: float = 5.0
@export var max_spawn_delay: float = 15.0

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	spawn_chair_after_random_delay()

func spawn_chair_after_random_delay() -> void:
	var random_delay = randf_range(min_spawn_delay, max_spawn_delay)
	await get_tree().create_timer(random_delay).timeout
	spawn_chair()
	spawn_chair_after_random_delay()

func spawn_chair() -> void:
	if not chair_scene:
		return
	var new_chair = chair_scene.instantiate()
	get_tree().root.add_child(new_chair)
