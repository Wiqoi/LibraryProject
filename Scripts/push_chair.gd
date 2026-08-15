extends "res://Scripts/hand_ss.gd"

# Chair pose to show while the event is active (pulled out). Leave empty to
# keep the animation configured on StudentLook in the scene.
@export var chair_animation: String = ""

var _initial_animation: String = ""

func _ready() -> void:
	# hand_ss._ready() plays the kid Idle pose, which would hide the chair
	# look. Remember the scene-configured animation first and restore it.
	_initial_animation = chair_animation if chair_animation != "" else String($StudentLook.animation)
	super._ready()
	interaction_text = "Pushing in chairs..."
	if animated_sprite:
		animated_sprite.play(_initial_animation)

func _complete_interaction() -> void:
	super._complete_interaction()
	# Chair is pushed in: swap the pulled-out pose for the pushed-in one
	# on the same side. Non-chair setups keep the Idle pose.
	if animated_sprite:
		match _initial_animation:
			"ChairsPulledOutLeft", "ChairPushedInLeft":
				animated_sprite.play("ChairPushedInLeft")
			"ChairsPulledOutRight", "ChairPushedInRight":
				animated_sprite.play("ChairPushedInRight")
			_:
				animated_sprite.play("Idle")

func firsttime():
	Global.firstChairs = 1
	Global.events_done += 1
	Global.chairs_done += 1
	if Global.chairs_done >= Global.chairs_total:
		Global.objectives_done[1] = true
