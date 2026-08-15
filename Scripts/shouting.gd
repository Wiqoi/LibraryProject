extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Quieting down..."

func firsttime():
	Global.firstNoise = 1
	Global.events_done += 1
	Global.shouting_done += 1
	if Global.shouting_done >= Global.shouting_total:
		Global.objectives_done[1] = true
