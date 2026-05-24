extends Node2D

func _process(delta: float) -> void:
	Global.Objectives = "res://TextFiles/Level1Objectives.txt"
	print(Global.lvl1dc)
	print($AllEvents.get_child_count())
	if($AllEvents.get_child_count() == Global.lvl1dc):
		Global.lvl1done = 1
		var game_scene = load("res://Scenes/UIFolders/LevelSelect.tscn")
		get_tree().change_scene_to_packed(game_scene)
