extends Button

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect the button's "pressed" signal to our custom function
	pressed.connect(_on_quit_pressed)

# Function to handle quit button press
func _on_quit_pressed():
	# Play the swing-out + fade before quitting.
	var page = get_tree().current_scene
	if page and page.has_method("play_exit"):
		await page.play_exit()
	get_tree().quit()
