extends Node2D

var _transitioning: bool = false

func _ready():
	Global.Objectives = "res://TextFiles/Level3Objectives.txt"
	Global.events_done = 0
	Global.objectives_done = [false, false, false, false]
	Global.objectives_revealed = [true, true, true, false]
	Global.level_transitioning = false
	Global.firstLeave = 0
	Global.events_total = $AllEvents.get_child_count()
	# Reset and count per-objective totals from the events placed in the level
	Global.checkout_done = 0
	Global.chairs_done = 0
	Global.leave_done = 0
	Global.lineup_done = 0
	Global.checkout_total = 0
	Global.chairs_total = 0
	Global.leave_total = 0
	Global.lineup_total = 0
	for child in $AllEvents.get_children():
		var n: String = child.name
		if n.begins_with("Checkout"):
			Global.checkout_total += 1
		elif n.begins_with("PushChair"):
			Global.chairs_total += 1
		elif n.begins_with("LineUp"):
			Global.lineup_total += 1
		elif n.begins_with("LeaveDoor"):
			Global.leave_total += 1

func _process(delta: float) -> void:
	if _transitioning:
		return
	if not Global.level_transitioning and Global.events_done >= Global.events_total and Global.events_total > 0:
		_transitioning = true
		Global.lvl3done = 1
		await get_tree().create_timer(0.5).timeout
		var game_scene = load("res://Scenes/UIFolders/VictoryScreen.tscn")
		get_tree().change_scene_to_packed(game_scene)
