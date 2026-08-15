extends Node2D

func _ready():
	Global.Objectives = "res://TextFiles/Level1Objectives.txt"
	Global.events_done = 0
	Global.sanitize_done = 0
	Global.cubby_done = 0
	Global.fighting_done = 0
	Global.enter_done = 0
	Global.objectives_done = [false, false, false, false]
	Global.objectives_revealed = [true, true, false, false]
	Global.level_transitioning = false
	Global.firstEnter = 0
	Global.events_total = Global.sanitize_total + Global.cubby_total + Global.fighting_total + Global.enter_total

func _process(delta: float) -> void:
	if not Global.level_transitioning and Global.events_done >= Global.events_total and Global.events_total > 0:
		Global.lvl1done = 1
		await get_tree().create_timer(0.5).timeout
		var game_scene = load("res://Scenes/UIFolders/LevelSelect.tscn")
		get_tree().change_scene_to_packed(game_scene)
