extends Control

const LEVEL_CONFIGS = {
	1: {"map_origin": Vector2(992, 728), "map_world_size": Vector2(512, 288), "minimap_size": Vector2(320, 180)},
	2: {"map_origin": Vector2(0, 0), "map_world_size": Vector2(592, 384), "minimap_size": Vector2(320, 208)},
	3: {"map_origin": Vector2(0, 0), "map_world_size": Vector2(512, 288), "minimap_size": Vector2(320, 180)},
}

@export var update_interval: float = 0.1
@export var background_alpha: float = 0.6

var _current_level: int = 0
var _update_timer: float = 0.0
var minimap_visible: bool = true

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
	var cfg = LEVEL_CONFIGS.get(_current_level, null)
	if not cfg:
		return

	var msize: Vector2 = cfg["minimap_size"]
	panel.size = msize + Vector2(4, 4)
	background_rect.size = msize
	markers_layer.size = msize

	var tex = _load_texture()
	if not tex:
		tex = _generate_background()
		if tex:
			_save_texture(tex)
	if tex:
		background_rect.texture = tex

	# Remove old event/student markers
	for m in event_markers:
		m.queue_free()
	event_markers.clear()
	for m in student_markers:
		m.queue_free()
	student_markers.clear()


func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var cfg = LEVEL_CONFIGS[_current_level]
	var origin: Vector2 = cfg["map_origin"]
	var world_size: Vector2 = cfg["map_world_size"]
	var msize: Vector2 = cfg["minimap_size"]
	var rel = world_pos - origin
	return Vector2((rel.x / world_size.x) * msize.x, (rel.y / world_size.y) * msize.y)


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
	var cfg = LEVEL_CONFIGS[_current_level]
	var msize: Vector2 = cfg["minimap_size"]
	var world_size: Vector2 = cfg["map_world_size"]
	var origin: Vector2 = cfg["map_origin"]

	var img = Image.create(int(msize.x), int(msize.y), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.08, 0.08, 0.14, 0.85))

	var ground = _find_tilemap_layer("Ground")
	var walls = _find_tilemap_layer("Walls")

	for tl in [{layer = ground, color = Color(0.25, 0.25, 0.35)}, {layer = walls, color = Color(0.08, 0.08, 0.12)}]:
		if not tl.layer:
			continue
		for cell in tl.layer.get_used_cells():
			var cell_world = tl.layer.to_global(tl.layer.map_to_local(cell))
			var rel = cell_world - origin
			var mx = int(rel.x / world_size.x * msize.x)
			var my = int(rel.y / world_size.y * msize.y)
			img.set_pixel(mx, my, tl.color)
			if mx + 1 < int(msize.x) and my + 1 < int(msize.y):
				img.set_pixel(mx + 1, my, tl.color)
				img.set_pixel(mx, my + 1, tl.color)
				img.set_pixel(mx + 1, my + 1, tl.color)

	return ImageTexture.create_from_image(img)


func _find_tilemap_layer(layer_name: String) -> TileMapLayer:
	var root = get_tree().current_scene
	if not root:
		return null
	for child in root.get_children():
		if _find_layer_in_node(child, layer_name):
			return _find_layer_in_node(child, layer_name)
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
		var cfg = LEVEL_CONFIGS.get(_current_level, null)
		if cfg:
			var msize: Vector2 = cfg["minimap_size"]
			panel.size = msize + Vector2(4, 4)
			toggle_btn.position = Vector2(panel.size.x - 22, 2)
	else:
		toggle_btn.text = "+"
		panel.size = Vector2(24, 20)
		toggle_btn.position = Vector2(2, 2)
