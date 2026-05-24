extends Button

func _ready():
	pressed.connect(_on_back_pressed)

func _on_back_pressed():
	var scene = load("res://Scenes/UIFolders/starting_page.tscn")
	get_tree().change_scene_to_packed(scene)
