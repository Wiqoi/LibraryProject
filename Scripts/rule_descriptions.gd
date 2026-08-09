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

func _ready() -> void:
	$QuizPanel/AnswerA.pressed.connect(func(): _on_answer(true))
	$QuizPanel/AnswerB.pressed.connect(func(): _on_answer(false))

var _quiz_answered: bool = false
var _quiz_picked_a: bool = false

func _on_answer(picked_a: bool) -> void:
	_quiz_answered = true
	_quiz_picked_a = picked_a

func _run_quiz(question: String, answer_a: String, answer_b: String, correct_is_a: bool) -> void:
	$QuizPanel/QuizQuestion.text = question
	$QuizPanel/AnswerA.text = answer_a
	$QuizPanel/AnswerB.text = answer_b
	$QuizPanel.visible = true
	_quiz_answered = false

	# Wait for button press (game is paused; process_frame still fires for Control with process_mode=3)
	while not _quiz_answered:
		await get_tree().process_frame

	var is_correct = (correct_is_a and _quiz_picked_a) or (not correct_is_a and not _quiz_picked_a)

	if not is_correct:
		if _quiz_picked_a:
			$QuizPanel/AnswerA.modulate = Color.RED
			await get_tree().create_timer(0.3).timeout
			$QuizPanel/AnswerA.modulate = Color.WHITE
		else:
			$QuizPanel/AnswerB.modulate = Color.RED
			await get_tree().create_timer(0.3).timeout
			$QuizPanel/AnswerB.modulate = Color.WHITE
		await get_tree().create_timer(0.8).timeout

	$QuizPanel.visible = false

func _process(delta: float) -> void:
	if Global.first_food == 1 && firstF == 0:
		firstF = 1
		Global.givenText = FileAccess.open("res://TextFiles/CollectFood.txt", FileAccess.READ).get_line()
		$Food.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("What should you do with food in the library?", "Clean it up and throw it away", "Leave it for someone else", true)
		get_tree().paused = false
		self.visible = false
		$Food.visible = false

	if Global.firstS == 1 && firstSanitize == 0:
		firstSanitize = 1
		Global.givenText = FileAccess.open("res://TextFiles/SanitizeHands.txt", FileAccess.READ).get_line()
		$Sanitize.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("Why is sanitizing hands important?", "Keeps books and space clean", "It makes hands smell nice", true)
		get_tree().paused = false
		self.visible = false
		$Sanitize.visible = false

	if Global.firstBook == 1 && firstBook == 0:
		firstBook = 1
		Global.givenText = FileAccess.open("res://TextFiles/BookOrganization.txt", FileAccess.READ).get_line()
		$Books.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("Where should books be returned?", "Back to their proper shelves", "Leave them on the floor", true)
		get_tree().paused = false
		self.visible = false
		$Books.visible = false

	if Global.firstBackpack == 1 && firstBackpack == 0:
		firstBackpack = 1
		Global.givenText = FileAccess.open("res://TextFiles/PlaceBackBackPack.txt", FileAccess.READ).get_line()
		$Backpack.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("Where do backpacks belong?", "Stowed in the cubbies", "On the floor", true)
		get_tree().paused = false
		self.visible = false
		$Backpack.visible = false

	if Global.firstFighting == 1 && firstFighting == 0:
		firstFighting = 1
		Global.givenText = FileAccess.open("res://TextFiles/NoFighting.txt", FileAccess.READ).get_line()
		$Fighting.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("What should you do instead of fighting?", "Keep the library peaceful", "Yell louder", true)
		get_tree().paused = false
		self.visible = false
		$Fighting.visible = false

	if Global.firstNoise == 1 && firstNoise == 0:
		firstNoise = 1
		Global.givenText = FileAccess.open("res://TextFiles/NoLoudNoises.txt", FileAccess.READ).get_line()
		$Noise.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("How should you speak in the library?", "Use a quiet voice", "Talk loudly", true)
		get_tree().paused = false
		self.visible = false
		$Noise.visible = false

	if Global.firstRunning == 1 && firstRunning == 0:
		firstRunning = 1
		Global.givenText = FileAccess.open("res://TextFiles/Running Around.txt", FileAccess.READ).get_line()
		$Running.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("Why shouldn't you run in the library?", "It can cause accidents", "It's not fun", true)
		get_tree().paused = false
		self.visible = false
		$Running.visible = false

	if Global.firstChairs == 1 && firstChairs == 0:
		firstChairs = 1
		Global.givenText = FileAccess.open("res://TextFiles/PushInChair.txt", FileAccess.READ).get_line()
		$Chairs.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("What should you do with chairs?", "Push them in when done", "Leave them pulled out", true)
		get_tree().paused = false
		self.visible = false
		$Chairs.visible = false

	if Global.firstCheckout == 1 && firstCheckout == 0:
		firstCheckout = 1
		Global.givenText = FileAccess.open("res://TextFiles/Checkout.txt", FileAccess.READ).get_line()
		$Checkout.visible = true
		self.visible = true
		get_tree().paused = true
		await get_tree().create_timer(6).timeout
		await _run_quiz("How do you properly borrow books?", "Check them out at the desk", "Take them without asking", true)
		get_tree().paused = false
		self.visible = false
		$Checkout.visible = false
