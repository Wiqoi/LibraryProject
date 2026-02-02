extends Button

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect the button's pressed signal to our custom function
	pressed.connect(_on_start_pressed)

# Custom function to handle start button click
func _on_start_pressed():
		# Load and switch to the game scene (replace "res://Game.tscn" with your actual game scene path)
	var game_scene = load("res://Scenes/game.tscn")
	get_tree().change_scene_to_packed(game_scene)
