extends Node2D

# Visual cue for the shouting event, for players who can't hear the audio:
# expanding sound-wave rings around the kid.
# Active while the kid is still shouting (parent.done == 0).

const RING_INTERVAL := 0.45         # Seconds between rings
const RING_LIFETIME := 1.5          # Seconds a ring stays visible
const RING_START_RADIUS := 8.0
const RING_END_RADIUS := 64.0
const RING_COLOR := Color(1.0, 0.4, 0.2)

@export var ring_center := Vector2(0, 12)

var _elapsed := 0.0
var _was_active := false

func _process(delta: float) -> void:
	var active: bool = get_parent() != null and get_parent().get("done") == 0
	if active:
		_elapsed += delta
		queue_redraw()
	elif _was_active:
		queue_redraw()  # Clear the last drawn frame once the kid is quieted
	_was_active = active

func _draw() -> void:
	if not _was_active:
		return
	# Draw every ring whose lifetime window contains the current time,
	# so rings keep spawning forever while the kid shouts.
	var current_wave := int(_elapsed / RING_INTERVAL)
	var first_wave := current_wave - int(RING_LIFETIME / RING_INTERVAL)
	for i in range(maxi(first_wave, 0), current_wave + 1):
		var age := _elapsed - i * RING_INTERVAL
		if age >= RING_LIFETIME:
			continue
		var t := age / RING_LIFETIME
		var radius := lerpf(RING_START_RADIUS, RING_END_RADIUS, t)
		var color := RING_COLOR
		color.a = (1.0 - t) * 0.8
		draw_arc(ring_center, radius, 0.0, TAU, 32, color, lerpf(3.5, 1.0, t), true)
