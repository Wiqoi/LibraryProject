extends "res://Scripts/hand_ss.gd"

func firsttime():
	Global.firstBackpack = 1
	Global.events_done += 1

func _complete_interaction() -> void:
	super._complete_interaction()
	self.visible = false
	self.position = Global.player_node.position
