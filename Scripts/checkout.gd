extends "res://Scripts/hand_ss.gd"

# 1-4; only the front of the queue is interactable at a time.
@export var queue_position: int = 1
# The kid's ORIGINAL static spot in the queue (never changes).
@export var queue_spot: Vector2 = Vector2.ZERO
# Spot in the horizontal line by the door (left to right).
@export var line_slot: Vector2 = Vector2.ZERO
# Stagger for the finale walk-out.
@export var walk_out_delay: float = 0.0

const WALK_SPEED := 83.0            # px/s (1/3 of the original 250)

var _walk_tween: Tween = null
var _last_checkout_done: int = -1

func _ready() -> void:
	super._ready()
	add_to_group("kids")
	add_to_group("checkout_queue")
	interaction_text = "Checking out books..."
	_last_checkout_done = Global.checkout_done

func firsttime():
	Global.firstCheckout = 1
	Global.events_done += 1
	Global.checkout_done += 1
	if Global.checkout_done >= Global.checkout_total:
		Global.objectives_done[0] = true

# Only the kid at the front of the queue can be interacted with.
func can_interact() -> bool:
	return done == 0 and Global.checkout_done + 1 == queue_position

func marker_visible() -> bool:
	return can_interact() and not Global.player_has_backpack and not Global.player_has_book

func _process(delta: float) -> void:
	super._process(delta)
	if Global.checkout_done != _last_checkout_done:
		_last_checkout_done = Global.checkout_done
		if done == 0 and Global.checkout_done > 0:
			_shuffle_up()

# Walk one spot forward in the queue (toward the front).
func _shuffle_up() -> void:
	var target_index: int = queue_position - Global.checkout_done
	if target_index < 1:
		return
	var target: Node = null
	for kid in get_tree().get_nodes_in_group("checkout_queue"):
		if kid != self and kid.queue_position == target_index:
			target = kid
			break
	if target == null:
		return
	var to_slot: Vector2 = target.queue_spot - global_position
	if _walk_tween and _walk_tween.is_valid():
		_walk_tween.kill()
	freeze = true
	_disable_collisions()
	_play_walk_anim(to_slot)
	var duration: float = clampf(to_slot.length() / WALK_SPEED, 0.6, 3.0)
	_walk_tween = create_tween()
	_walk_tween.tween_property(self, "global_position", target.queue_spot, duration).set_ease(Tween.EASE_IN_OUT)
	_walk_tween.tween_callback(func() -> void:
		if animated_sprite:
			animated_sprite.play("Idle"))

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

func _complete_interaction() -> void:
	super._complete_interaction()  # firsttime(), marker removal, done = 1
	_exit_queue()

# Leave the queue: -76 x, then +200 y, then walk to the kid's spot in the line.
func _exit_queue() -> void:
	freeze = true
	is_walking_away = true
	_disable_collisions()
	if _walk_tween and _walk_tween.is_valid():
		_walk_tween.kill()
	var pts: Array[Vector2] = [
		global_position + Vector2(-76, 0),
		global_position + Vector2(-76, 200),
		line_slot,
	]
	var prev: Vector2 = global_position
	_walk_tween = create_tween()
	for p in pts:
		var leg: Vector2 = p - prev
		_walk_tween.tween_callback(func() -> void: _play_walk_anim(leg))
		_walk_tween.tween_property(self, "global_position", p, clampf(leg.length() / WALK_SPEED, 0.75, 4.5)).set_ease(Tween.EASE_IN_OUT)
		prev = p
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
