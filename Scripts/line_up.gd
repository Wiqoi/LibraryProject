extends "res://Scripts/hand_ss.gd"

# World position the kid walks to once told to line up (set per instance in level3.tscn).
@export var lineup_slot: Vector2 = Vector2.ZERO
# Delay before this kid starts walking out during the finale (stagger).
@export var walk_out_delay: float = 0.0

const WALK_SPEED := 83.0            # px/s (1/3 of the original 250)

var _walk_tween: Tween = null

func _ready() -> void:
	super._ready()
	add_to_group("kids")
	interaction_text = "Telling kids to line up..."

func firsttime():
	Global.events_done += 1
	Global.lineup_done += 1
	if Global.lineup_done >= Global.lineup_total:
		Global.objectives_done[2] = true

func _complete_interaction() -> void:
	super._complete_interaction()  # signals, firsttime(), marker removal, done = 1
	walk_to_line()

func _disable_collisions() -> void:
	if has_node("Collisions"):
		$Collisions.set_deferred("disabled", true)

func _play_walk_anim(dir_v: Vector2) -> void:
	if not animated_sprite:
		return
	animated_sprite.flip_h = false
	if absf(dir_v.x) >= absf(dir_v.y):
		animated_sprite.play("WalkRight" if dir_v.x >= 0.0 else "WalkLeft")
	else:
		animated_sprite.play("WalkDown" if dir_v.y >= 0.0 else "WalkUp")

func walk_to_line() -> void:
	freeze = true
	is_walking_away = true
	_disable_collisions()
	var to_slot: Vector2 = lineup_slot - global_position
	_play_walk_anim(to_slot)
	var duration: float = clampf(to_slot.length() / WALK_SPEED, 3.0, 8.5)
	_walk_tween = create_tween()
	_walk_tween.tween_property(self, "global_position", lineup_slot, duration).set_ease(Tween.EASE_IN_OUT)
	_walk_tween.tween_callback(func() -> void:
		if animated_sprite:
			animated_sprite.play("Idle")
			animated_sprite.flip_h = true)  # Face right while waiting in the line

# Called by the final door: walk out toward the right of the screen.
func walk_out() -> void:
	if _walk_tween and _walk_tween.is_valid():
		_walk_tween.kill()
	freeze = true
	is_walking_away = true
	_disable_collisions()
	if animated_sprite:
		animated_sprite.flip_h = false
		animated_sprite.play("WalkRight")
	var tween = create_tween()
	if walk_out_delay > 0.0:
		tween.tween_interval(walk_out_delay)
	tween.tween_property(self, "global_position", global_position + Vector2(600, 0), 6.6).set_ease(Tween.EASE_IN_OUT)
