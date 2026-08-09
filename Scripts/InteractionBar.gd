extends Control

@export var fill_duration: float = 3.5

const CELEBRATION_SCENE = preload("res://Scenes/EventFolders/CelebrationEffect.tscn")

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var action_label: Label = $ActionLabel

func _ready() -> void:
	visible = false
	Global.interaction_started.connect(_on_interaction_started)
	Global.interaction_progress.connect(_on_interaction_progress)
	Global.interaction_finished.connect(_on_interaction_finished)
	Global.task_completed.connect(_on_task_completed)

func _on_interaction_started(action_text: String) -> void:
	action_label.text = action_text
	progress_bar.value = 0.0
	visible = true

func _on_interaction_progress(ratio: float) -> void:
	progress_bar.value = ratio * 100.0

func _on_interaction_finished() -> void:
	visible = false

func _on_task_completed(world_pos: Vector2) -> void:
	var celebration = CELEBRATION_SCENE.instantiate()
	# Convert world position to screen position relative to the HUD
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport().get_visible_rect().size
		var screen_pos = (world_pos - camera.global_position) * camera.zoom + viewport_size / 2
		celebration.position = screen_pos - Vector2(169, 100)
	else:
		celebration.position = get_viewport().get_visible_rect().size / 2 - Vector2(100, 130)
	get_parent().add_child(celebration)
