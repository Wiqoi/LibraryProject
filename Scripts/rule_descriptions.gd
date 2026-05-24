extends Control

var firstF = 0
var firstSanitize = 0
var firstBook = 0
var firstBackpack = 0
var firstFighting = 0
var firstNoise = 0
var firstRunning = 0
var firstChairs = 0
var firstCheckout = 0

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
	if Global.firstBackpack == 1 && firstBackpack == 0:
		Global.givenText = FileAccess.open("res://TextFiles/PlaceBackBackPack.txt", FileAccess.READ).get_line()
		$Backpack.visible = true
		self.visible = true
		firstBackpack = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Backpack.visible = false
	if Global.firstFighting == 1 && firstFighting == 0:
		Global.givenText = FileAccess.open("res://TextFiles/NoFighting.txt", FileAccess.READ).get_line()
		$Fighting.visible = true
		self.visible = true
		firstFighting = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Fighting.visible = false
	if Global.firstNoise == 1 && firstNoise == 0:
		Global.givenText = FileAccess.open("res://TextFiles/NoLoudNoises.txt", FileAccess.READ).get_line()
		$Noise.visible = true
		self.visible = true
		firstNoise = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Noise.visible = false
	if Global.firstRunning == 1 && firstRunning == 0:
		Global.givenText = FileAccess.open("res://TextFiles/Running Around.txt", FileAccess.READ).get_line()
		$Running.visible = true
		self.visible = true
		firstRunning = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Running.visible = false
	if Global.firstChairs == 1 && firstChairs == 0:
		Global.givenText = FileAccess.open("res://TextFiles/PushInChair.txt", FileAccess.READ).get_line()
		$Chairs.visible = true
		self.visible = true
		firstChairs = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Chairs.visible = false
	if Global.firstCheckout == 1 && firstCheckout == 0:
		Global.givenText = FileAccess.open("res://TextFiles/Checkout.txt", FileAccess.READ).get_line()
		$Checkout.visible = true
		self.visible = true
		firstCheckout = 1
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		get_tree().paused = false
		self.visible = false
		$Checkout.visible = false
	
		
