extends Control

const MINIMAP_SIZES = {
	1: Vector2(320, 180),
	2: Vector2(320, 208),
	3: Vector2(320, 180),
}

@export var update_interval: float = 0.1
@export var background_alpha: float = 0.6

var _current_level: int = 0
var _update_timer: float = 0.0
var minimap_visible: bool = true
var _map_origin: Vector2 = Vector2.ZERO
var _map_world_size: Vector2 = Vector2.ONE
var _minimap_size: Vector2 = Vector2(320, 180)

var player_marker: ColorRect
var event_markers: Array = []
var student_markers: Array = []

@onready var background_rect: TextureRect = $Panel/Background
@onready var markers_layer: Control = $Panel/Markers
@onready var panel: Panel = $Panel
@onready var toggle_btn: Button = $ToggleButton


func _ready() -> void:
	toggle_btn.pressed.connect(_toggle)
	player_marker = ColorRect.new()
	player_marker.size = Vector2(10, 10)
	player_marker.color = Color.GREEN
	markers_layer.add_child(player_marker)

	await get_tree().create_timer(0.3).timeout
	_setup_minimap()


func _process(delta: float) -> void:
	var detected = _detect_level()
	if detected != _current_level:
		_current_level = detected
		_setup_minimap()

	if not _current_level:
		hide()
		return

	if minimap_visible:
		background_rect.show()
		markers_layer.show()
		_update_timer += delta
		if _update_timer >= update_interval:
			_update_timer = 0.0
			_update_player_marker()
			_update_event_markers()
			_update_student_markers()
	else:
		background_rect.hide()
		markers_layer.hide()

	if Input.is_action_just_pressed("minimap_toggle"):
		_toggle()


func _detect_level() -> int:
	var path = get_tree().current_scene.scene_file_path
	if path.ends_with("level1.tscn") or path.ends_with("game.tscn"):
		return 1
	elif path.ends_with("level2.tscn"):
		return 2
	elif path.ends_with("level3.tscn"):
		return 3
	return 0


func _setup_minimap() -> void:
	_minimap_size = MINIMAP_SIZES.get(_current_level, Vector2(320, 180))
	_compute_map_bounds()

	panel.size = _minimap_size + Vector2(4, 4)
	background_rect.size = _minimap_size
	markers_layer.size = _minimap_size
	toggle_btn.position = Vector2(panel.size.x - 22, 2)

	var tex = _load_texture()
	if not tex:
		tex = _generate_background()
		if tex:
			_save_texture(tex)
	if tex:
		background_rect.texture = tex

	for m in event_markers:
		m.queue_free()
	event_markers.clear()
	for m in student_markers:
		m.queue_free()
	student_markers.clear()


func _compute_map_bounds() -> void:
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)

	# Include tilemap cells
	for layer_name in ["Ground", "Walls"]:
		var tl = _find_tilemap_layer(layer_name)
		if tl:
			for cell in tl.get_used_cells():
				var wp = tl.to_global(tl.map_to_local(cell))
				min_pos = min_pos.min(wp)
				max_pos = max_pos.max(wp)

	# Include player
	if Global.player_node:
		var pp = Global.player_node.global_position
		min_pos = min_pos.min(pp)
		max_pos = max_pos.max(pp)

	# Include events
	var events = _find_all_events_node()
	if events:
		for child in events.get_children():
			if is_instance_valid(child) and child is Node2D:
				min_pos = min_pos.min(child.global_position)
				max_pos = max_pos.max(child.global_position)

	# Include students (outside AllEvents)
	for s in _find_students():
		if is_instance_valid(s):
			min_pos = min_pos.min(s.global_position)
			max_pos = max_pos.max(s.global_position)

	if min_pos.x == INF:
		return

	var size = max_pos - min_pos
	var pad = Vector2(max(size.x * 0.1, 50), max(size.y * 0.1, 50))
	_map_origin = min_pos - pad
	_map_world_size = size + pad * 2


func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var rel = world_pos - _map_origin
	return Vector2(
		(rel.x / _map_world_size.x) * _minimap_size.x,
		(rel.y / _map_world_size.y) * _minimap_size.y
	)


func _update_player_marker() -> void:
	if not Global.player_node:
		return
	var mpos = _world_to_minimap(Global.player_node.global_position)
	player_marker.position = mpos - player_marker.size * 0.5


func _update_event_markers() -> void:
	var all_events = _find_all_events_node()
	if not all_events:
		return

	var children = all_events.get_children()
	var needed = children.size()

	while event_markers.size() < needed:
		var m = ColorRect.new()
		m.size = Vector2(6, 6)
		m.color = Color.RED
		event_markers.append(m)
		markers_layer.add_child(m)
	while event_markers.size() > needed:
		var m: ColorRect = event_markers.pop_back()
		m.queue_free()

	for i in needed:
		var marker: ColorRect = event_markers[i]
		var child = children[i]
		if is_instance_valid(child):
			var mpos = _world_to_minimap(child.global_position)
			marker.position = mpos - marker.size * 0.5
			marker.visible = true


func _update_student_markers() -> void:
	var students = _find_students()
	var needed = students.size()

	while student_markers.size() < needed:
		var m = ColorRect.new()
		m.size = Vector2(6, 6)
		m.color = Color.YELLOW
		student_markers.append(m)
		markers_layer.add_child(m)
	while student_markers.size() > needed:
		var m: ColorRect = student_markers.pop_back()
		m.queue_free()

	for i in needed:
		var marker: ColorRect = student_markers[i]
		if is_instance_valid(students[i]):
			var mpos = _world_to_minimap(students[i].global_position)
			marker.position = mpos - marker.size * 0.5
			marker.visible = true


func _find_all_events_node() -> Node:
	var root = get_tree().current_scene
	if root and root.has_node("AllEvents"):
		return root.get_node("AllEvents")
	return null


func _find_students() -> Array:
	var root = get_tree().current_scene
	var out: Array = []
	if not root:
		return out
	if root.has_node("Students"):
		for child in root.get_node("Students").get_children():
			if child is CharacterBody2D:
				out.append(child)
	return out


func _load_texture() -> Texture2D:
	var path = "res://Assets/Minimaps/level%d_minimap.png" % _current_level
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _save_texture(tex: ImageTexture) -> void:
	var path = "user://level%d_minimap.png" % _current_level
	var img = tex.get_image()
	if img:
		img.save_png(path)


func _generate_background() -> ImageTexture:
	var img = Image.create(int(_minimap_size.x), int(_minimap_size.y), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.08, 0.08, 0.14, 0.85))

	var ground = _find_tilemap_layer("Ground")
	var walls = _find_tilemap_layer("Walls")

	for tl in [{layer = ground, color = Color(0.25, 0.25, 0.35)}, {layer = walls, color = Color(0.08, 0.08, 0.12)}]:
		if not tl.layer:
			continue
		for cell in tl.layer.get_used_cells():
			var cell_world = tl.layer.to_global(tl.layer.map_to_local(cell))
			var rel = cell_world - _map_origin
			var mx = int(rel.x / _map_world_size.x * _minimap_size.x)
			var my = int(rel.y / _map_world_size.y * _minimap_size.y)
			img.set_pixel(mx, my, tl.color)
			if mx + 1 < int(_minimap_size.x) and my + 1 < int(_minimap_size.y):
				img.set_pixel(mx + 1, my, tl.color)
				img.set_pixel(mx, my + 1, tl.color)
				img.set_pixel(mx + 1, my + 1, tl.color)

	return ImageTexture.create_from_image(img)


func _find_tilemap_layer(layer_name: String) -> TileMapLayer:
	var root = get_tree().current_scene
	if not root:
		return null
	for child in root.get_children():
		var found = _find_layer_in_node(child, layer_name)
		if found:
			return found
	return null


func _find_layer_in_node(node: Node, layer_name: String) -> TileMapLayer:
	if node is TileMapLayer and node.name == layer_name:
		return node
	for child in node.get_children():
		var found = _find_layer_in_node(child, layer_name)
		if found:
			return found
	return null


func _toggle() -> void:
	minimap_visible = not minimap_visible
	if minimap_visible:
		toggle_btn.text = "-"
		panel.size = _minimap_size + Vector2(4, 4)
		toggle_btn.position = Vector2(panel.size.x - 22, 2)
	else:
		toggle_btn.text = "+"
		panel.size = Vector2(24, 20)
		toggle_btn.position = Vector2(2, 2)
