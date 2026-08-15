extends Node2D
# Points the player at an available interactable:
# - a pulsing green border box around the target
# - a trail of arrows pointing from the player to the target

const ARROW_SPACING: float = 36.0

var arrow_points: PackedVector2Array = PackedVector2Array([
	Vector2(0, 6), Vector2(12, 0), Vector2(0, -6)
])

var border_line: Line2D
var current_target: Node2D = null
var pulse_time: float = 0.0
var arrow_lines: Array = []


func _ready() -> void:
	border_line = Line2D.new()
	border_line.width = 4.0
	border_line.default_color = Color(0.2, 1.0, 0.35, 0.9)
	border_line.closed = true
	border_line.z_index = 4000
	add_child(border_line)


func _pick_new_target() -> void:
	var available: Array = []
	for obj in get_tree().get_nodes_in_group("interactables"):
		if is_instance_valid(obj) and obj.has_method("is_available") and obj.is_available():
			available.append(obj)
	current_target = available.pick_random() if available.size() > 0 else null


func _process(delta: float) -> void:
	# Re-pick when the current target is no longer available
	if current_target == null or not is_instance_valid(current_target) or not current_target.has_method("is_available") or not current_target.is_available():
		_pick_new_target()

	if current_target == null or Global.level_transitioning:
		border_line.visible = false
		_set_arrows_visible(false)
		return

	border_line.visible = true

	# Pulsing alpha, shared by the border and the arrows.
	pulse_time += delta
	modulate.a = 0.55 + 0.35 * sin(pulse_time * 4.0)

	# Pulsing green border box around the target (fixed size).
	var pos: Vector2 = current_target.global_position
	var half: float = 14.0
	border_line.points = PackedVector2Array([
		pos + Vector2(-half, -half),
		pos + Vector2(half, -half),
		pos + Vector2(half, half),
		pos + Vector2(-half, half),
		pos + Vector2(-half, -half)
	])

	# Arrow trail from the player toward the target.
	var player = Global.player_node
	if player:
		_update_arrows(player.global_position, current_target.global_position)


func _update_arrows(from: Vector2, to: Vector2) -> void:
	var dir := to - from
	var dist := dir.length()
	var count := 0
	if dist > ARROW_SPACING:
		# Last arrow stays at least one spacing away from the target.
		count = int(dist / ARROW_SPACING) - 1

	# Grow or shrink the arrow pool to the needed count.
	while arrow_lines.size() < count:
		var arrow := Line2D.new()
		arrow.points = arrow_points
		arrow.closed = true
		arrow.width = 4.0
		arrow.default_color = Color(0.3, 1.0, 0.4, 1.0)
		arrow.z_index = 4000
		add_child(arrow)
		arrow_lines.append(arrow)
	while arrow_lines.size() > count:
		var arrow: Line2D = arrow_lines.pop_back()
		arrow.queue_free()

	if count == 0:
		return

	var angle := dir.angle()
	for i in count:
		var arrow: Line2D = arrow_lines[i]
		arrow.visible = true
		arrow.position = from + dir * ((i + 1) * ARROW_SPACING / dist)
		arrow.rotation = angle


func _set_arrows_visible(visible: bool) -> void:
	for arrow in arrow_lines:
		arrow.visible = visible
