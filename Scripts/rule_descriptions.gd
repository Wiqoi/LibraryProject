extends Control

var firstF = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.first_food == 1 && firstF == 0:
		self.visible = true
		firstF = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		
