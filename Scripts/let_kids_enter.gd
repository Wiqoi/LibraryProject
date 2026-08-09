extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Letting kids enter..."

func firsttime():
	Global.firstEnter = 1
	Global.events_done += 1
