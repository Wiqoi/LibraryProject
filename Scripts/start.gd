extends Button

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect the button's pressed signal to our custom function
	pressed.connect(_on_start_pressed)

# Custom function to handle start button click
func _on_start_pressed():
	# Play the swing-out + fade before switching scenes.
	var page = get_tree().current_scene
	if page and page.has_method("play_exit"):
		await page.play_exit()
	var game_scene = load("res://Scenes/UIFolders/LevelSelect.tscn")
	get_tree().change_scene_to_packed(game_scene)
