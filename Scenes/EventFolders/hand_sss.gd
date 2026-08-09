extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Sanitizing hands..."

func firsttime():
	Global.firstS = 1
	Global.events_done += 1
