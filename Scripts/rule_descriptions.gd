extends Control

var firstF = 0
var firstSanitize = 0
var firstBook = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.first_food == 1 && firstF == 0:
		Global.givenText = FileAccess.open("res://TextFiles/CollectFood.txt", FileAccess.READ).get_line()
		$Food.visible = true
		self.visible = true
		firstF = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Food.visible = false
	if Global.firstS == 1 && firstSanitize == 0:
		Global.givenText = FileAccess.open("res://TextFiles/SanitizeHands.txt", FileAccess.READ).get_line()
		$Sanitize.visible = true
		self.visible = true
		firstSanitize = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Sanitize.visible = false
	if Global.firstBook == 1 && firstBook == 0:
		Global.givenText = FileAccess.open("res://TextFiles/BookOrganization.txt", FileAccess.READ).get_line()
		$Books.visible = true
		self.visible = true
		firstBook = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Books.visible = false
	
		
