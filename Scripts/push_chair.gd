extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Pushing in chairs..."

func firsttime():
	Global.firstChairs = 1
	Global.events_done += 1
