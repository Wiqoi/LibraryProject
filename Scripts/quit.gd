extends Button

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect the button's "pressed" signal to our custom function
	pressed.connect(_on_quit_pressed)

# Function to handle quit button press
func _on_quit_pressed():
	# Quit the game (works for desktop, mobile, etc.)
	get_tree().quit()
