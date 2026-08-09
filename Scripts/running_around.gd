extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Stopping the running..."

func firsttime():
	Global.firstRunning = 1
	Global.events_done += 1
