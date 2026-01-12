extends Node

@export var book_scene: PackedScene
@export var min_spawn_delay: float = 1.0
@export var max_spawn_delay: float = 2.0

func _ready() -> void:
	spawn_book_after_random_delay()

func spawn_book_after_random_delay() -> void:
	var random_delay = randf_range(min_spawn_delay, max_spawn_delay)
	await get_tree().create_timer(random_delay).timeout
	spawn_book()
	spawn_book_after_random_delay()

func spawn_book() -> void:
	if not book_scene:
		return
	var new_book = book_scene.instantiate()
	get_tree().root.add_child(new_book)
