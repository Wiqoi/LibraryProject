extends "res://Scripts/hand_ss.gd"

func firsttime():
	Global.firstBackpack = 1
	Global.events_done += 1

func _on_animation_finished() -> void:
	var anim_name = animated_sprite.animation
	firsttime()
	if anim_name == "Sanitize":
		remove_child($ObjectMarker)
		done = 1
		animated_sprite.animation = "Idle"
		self.visible = false
		self.position = Global.player_node.position
