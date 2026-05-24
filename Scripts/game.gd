extends Node2D

func _ready():
	Global.Objectives = "res://TextFiles/Level1Objectives.txt"
	Global.events_done = 0
	Global.events_total = $AllEvents.get_child_count()

func _process(delta: float) -> void:
	if Global.events_done >= Global.events_total and Global.events_total > 0:
		Global.lvl1done = 1
		await get_tree().create_timer(0.5).timeout
		var game_scene = load("res://Scenes/UIFolders/LevelSelect.tscn")
		get_tree().change_scene_to_packed(game_scene)
