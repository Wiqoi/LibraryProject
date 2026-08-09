extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Breaking up the fight..."

func firsttime():
	Global.firstFighting = 1
	Global.events_done += 1
