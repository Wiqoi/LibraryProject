extends "res://Scripts/hand_ss.gd"

# Phase designations set per-instance in level1.tscn
@export var is_fighter: bool = false

var phase: String = "sanitize"

func _ready() -> void:
	super._ready()
	add_to_group("kids")
	interaction_text = "Sanitizing hands..."

func _update_phase() -> void:
	if phase == "clean":
		if is_fighter and Global.fighting_done == 0 and Global.sanitize_done >= Global.sanitize_total:
			phase = "fighting"
			Global.objectives_revealed[2] = true

func _process(delta: float) -> void:
	_update_phase()

	if phase == "fighting":
		interaction_text = "Breaking up the fight..."
	else:
		interaction_text = "Sanitizing hands..."

	# Forward walk animation whenever the student moves (any direction)
	if animated_sprite and not is_walking_away:
		if self.linear_velocity.length() > 5.0:
			if animated_sprite.animation != "Walk":
				animated_sprite.play("Walk")
		elif animated_sprite.animation == "Walk":
			animated_sprite.play("Idle")

	super._process(delta)

func can_interact() -> bool:
	return done == 0 and (phase == "sanitize" or phase == "fighting")

func marker_visible() -> bool:
	return can_interact() and not Global.player_has_backpack

func start_walking() -> void:
	done = 1
	is_walking_away = true
	freeze = true
	if has_node("ObjectMarker"):
		$ObjectMarker.visible = false
	# Walk forward (left) toward the library entrance
	if animated_sprite:
		animated_sprite.play("Walk")
	var target = global_position + Vector2(-320, 0)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target, 2.2).set_ease(Tween.EASE_IN_OUT)

func _complete_interaction() -> void:
	is_organizing = false
	interaction_elapsed = 0.0
	Global.is_interacting = false
	Global.interaction_finished.emit()
	Global.task_completed.emit(global_position)

	if phase == "sanitize":
		if Global.firstS == 0:
			Global.firstS = 1
		Global.sanitize_done += 1
		Global.events_done += 1
		phase = "clean"
		if Global.sanitize_done >= Global.sanitize_total:
			Global.objectives_done[0] = true

	elif phase == "fighting":
		if Global.firstFighting == 0:
			Global.firstFighting = 1
		Global.fighting_done += 1
		Global.events_done += 1
		Global.objectives_done[2] = true
		phase = "clean"

	if animated_sprite:
		animated_sprite.animation = "Idle"
