extends "res://Scripts/hand_ss.gd"

func _ready() -> void:
	super._ready()
	interaction_text = "Checking out books..."

func firsttime():
	Global.firstCheckout = 1
	Global.events_done += 1
