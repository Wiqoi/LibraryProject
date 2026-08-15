extends Node2D

var _transitioning: bool = false

func _ready():
	Global.Objectives = "res://TextFiles/Level3Objectives.txt"
	Global.events_done = 0
	Global.objectives_done = [false, false, false, false]
	Global.objectives_revealed = [true, true, true, true]
	Global.level_transitioning = false
	Global.events_total = $AllEvents.get_child_count()

func _process(delta: float) -> void:
	if _transitioning:
		return
	if Global.events_done >= Global.events_total and Global.events_total > 0:
		_transitioning = true
		Global.lvl3done = 1
		await get_tree().create_timer(0.5).timeout
		var game_scene = load("res://Scenes/UIFolders/VictoryScreen.tscn")
		get_tree().change_scene_to_packed(game_scene)
