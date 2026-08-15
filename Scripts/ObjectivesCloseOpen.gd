extends TextureButton
# Opens/closes the objective list.
# Swaps instantly between the toggle-on and toggle-off textures:
# - toggle-off while the list is open (press to close)
# - toggle-on while the list is closed (press to open)
# The menu (background + text) swings in from the right of the screen and
# swings back out to the right.
# Greys out while the mouse hovers over it.

const TOGGLE_ON_TEXTURE_PATH: String = "res://Assets/GUI-HUDASSETS/UI_Flat_ToggleOn03a.png"
const TOGGLE_OFF_TEXTURE_PATH: String = "res://Assets/GUI-HUDASSETS/UI_Flat_ToggleOff03a.png"

@export var open_texture: Texture2D   # toggle-on — shown while the list is closed
@export var closed_texture: Texture2D # toggle-off — shown while the list is open
@export var hover_tint: Color = Color(0.6, 0.6, 0.6, 1.0)
@export var slide_in_duration: float = 0.8
@export var slide_duration: float = 0.4
@export var slide_distance: float = 600.0

var is_open: bool = true
var _normal_tint: Color = Color.WHITE
var _menu: Control
var _menu_base_pos: Vector2
var _menu_tween: Tween


func _ready() -> void:
	# Load the textures directly from disk so the toggle works even if the
	# editor drops the exported assignments when saving the scene.
	if open_texture == null:
		open_texture = load(TOGGLE_ON_TEXTURE_PATH)
	if closed_texture == null:
		closed_texture = load(TOGGLE_OFF_TEXTURE_PATH)
	_normal_tint = modulate
	_menu = $"../MenuBar"
	_menu_base_pos = _menu.position
	pressed.connect(_on_pressed)
	mouse_entered.connect(_set_hover.bind(true))
	mouse_exited.connect(_set_hover.bind(false))
	_update_view(false)


func _set_hover(hovering: bool) -> void:
	modulate = hover_tint if hovering else _normal_tint


func _on_pressed() -> void:
	is_open = not is_open
	_update_view(true)


func _update_view(animate: bool) -> void:
	if is_open:
		if closed_texture:
			texture_normal = closed_texture
		$"../ObjectiveList".show()
		_menu.show()
		if animate:
			_slide_menu(true)
	else:
		if open_texture:
			texture_normal = open_texture
		$"../ObjectiveList".hide()
		if animate:
			_slide_menu(false)
		else:
			_menu.hide()


func _slide_menu(show: bool) -> void:
	# Kill any slide still running so overlapping presses can't fight over position.
	if _menu_tween:
		_menu_tween.kill()
	var t := create_tween()
	_menu_tween = t
	if show:
		# Swing in from off-screen right with a bounce.
		_menu.visible = true
		_menu.position = _menu_base_pos + Vector2(slide_distance, 0)
		t.tween_property(_menu, "position", _menu_base_pos, slide_in_duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	else:
		# Swing back out to the right, then hide.
		t.tween_property(_menu, "position", _menu_base_pos + Vector2(slide_distance, 0), slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_callback(_menu.hide)
