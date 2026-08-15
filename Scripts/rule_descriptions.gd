extends Control
# Rule-description screens: poster + text + 4-answer quiz appear together and
# swing straight down. The game pauses while a rule is being shown. Wrong quiz
# answers stay red until the correct one is picked, then the whole page drops
# down off the bottom of the screen.

var _quiz_answered: bool = false
var _quiz_picked: int = 0
var _quiz_buttons: Array = []
var _base_positions: Dictionary = {}


func _ready() -> void:
	_quiz_buttons = [$QuizPanel/AnswerA, $QuizPanel/AnswerB, $QuizPanel/AnswerC, $QuizPanel/AnswerD]
	for i in _quiz_buttons.size():
		_quiz_buttons[i].pressed.connect(_on_answer.bind(i))


func _on_answer(picked: int) -> void:
	_quiz_answered = true
	_quiz_picked = picked


func _get_base(node: Control) -> Vector2:
	# Remember where a node normally sits, so animations can return it there.
	if not _base_positions.has(node):
		_base_positions[node] = node.position
	return _base_positions[node]


# "Already shown" state lives in Global so it survives level changes —
# otherwise level-1 rules re-trigger their quiz when level 2 loads.
func _was_shown(key: String) -> bool:
	return Global.rules_shown.get(key, false)


func _mark_shown(key: String) -> void:
	Global.rules_shown[key] = true


func _swing_down(node: Control, offset: float = -40.0) -> void:
	# Straight-down drop with a bounce. Runs while paused because the tweens
	# are bound to this node (process_mode = 3, PROCESS_MODE_WHEN_PAUSED).
	var base := _get_base(node)
	node.position = base + Vector2(0, offset)
	var t := create_tween()
	t.tween_property(node, "position", base, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _drop_out_page(nodes: Array) -> Tween:
	# One tween that slides every part of the rule page straight down off the
	# bottom of the screen (single tween so we only await one `finished`).
	var t := create_tween()
	t.set_parallel(true)
	for node in nodes:
		t.tween_property(node, "position", _get_base(node) + Vector2(0, 800), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return t


func _show_rule(key: String, text_file: String, poster: Control, question: String, answers: Array, correct_index: int) -> void:
	_mark_shown(key)
	Global.givenText = FileAccess.open(text_file, FileAccess.READ).get_line()
	poster.visible = true
	$QuizPanel.visible = true
	self.visible = true
	get_tree().paused = true

	# Poster, text panel and quiz all swing down at the same time.
	_swing_down(poster)
	_swing_down($ColorRect)
	_swing_down($RichTextLabel)
	_swing_down($QuizPanel)

	await _run_quiz(question, answers, correct_index)

	# Drop the whole rule page down below the screen.
	var page: Array = [poster, $ColorRect, $RichTextLabel, $QuizPanel]
	await _drop_out_page(page).finished

	get_tree().paused = false
	self.visible = false
	poster.visible = false
	$QuizPanel.visible = false
	for node in page:
		node.position = _get_base(node)


func _run_quiz(question: String, answers: Array, correct_index: int) -> void:
	$QuizPanel/QuizQuestion.text = question
	# Shuffle the answer positions so the correct one isn't always in the same spot.
	var order: Array = [0, 1, 2, 3]
	order.shuffle()
	var shuffled_correct := order.find(correct_index)
	for i in _quiz_buttons.size():
		_quiz_buttons[i].text = answers[order[i]]
		_quiz_buttons[i].modulate = Color.WHITE
		_quiz_buttons[i].disabled = false

	# Keep asking until the correct answer is picked; wrong picks stay red.
	while true:
		_quiz_answered = false
		while not _quiz_answered:
			await get_tree().process_frame
		if _quiz_picked == shuffled_correct:
			break
		_quiz_buttons[_quiz_picked].modulate = Color.RED
		_quiz_buttons[_quiz_picked].disabled = true
		await get_tree().create_timer(0.4).timeout


func _process(delta: float) -> void:
	if Global.first_food == 1 && not _was_shown("food"):
		await _show_rule("food", "res://TextFiles/CollectFood.txt", $Food,
			"Should food be allowed in the library?",
			["Food should not be in the library", "Yes, food is fine anywhere", "Only if it is wrapped", "Food keeps the library cozy"], 0)

	if Global.firstS == 1 && not _was_shown("sanitize"):
		await _show_rule("sanitize", "res://TextFiles/SanitizeHands.txt", $Sanitize,
			"Why is sanitizing hands important?",
			["Keeps books and space clean", "It makes hands smell nice", "It is not important", "Only when someone is watching"], 0)

	if Global.firstBook == 1 && not _was_shown("books"):
		await _show_rule("books", "res://TextFiles/BookOrganization.txt", $Books,
			"Where should books be returned?",
			["Back to their proper shelves", "Leave them on the floor", "Throw them in the trash", "Hide them behind a shelf"], 0)

	if Global.firstBackpack == 1 && not _was_shown("backpack"):
		await _show_rule("backpack", "res://TextFiles/PlaceBackBackPack.txt", $Backpack,
			"Where do backpacks belong?",
			["Stowed in the cubbies", "On the floor", "Swing it around", "Leave it in the doorway"], 0)

	if Global.firstFighting == 1 && not _was_shown("fighting"):
		await _show_rule("fighting", "res://TextFiles/NoFighting.txt", $Fighting,
			"What should you do instead of fighting?",
			["Keep the library peaceful", "Yell louder", "Push them first", "Keep fighting until you win"], 0)

	if Global.firstNoise == 1 && not _was_shown("noise"):
		await _show_rule("noise", "res://TextFiles/NoLoudNoises.txt", $Noise,
			"How should you speak in the library?",
			["Use a quiet voice", "Talk loudly", "Shout across the room", "Play music without headphones"], 0)

	if Global.firstRunning == 1 && not _was_shown("running"):
		await _show_rule("running", "res://TextFiles/Running Around.txt", $Running,
			"Why shouldn't you run in the library?",
			["It can cause accidents", "It's not fun", "Only run when nobody is looking", "Walking is too slow"], 0)

	if Global.firstChairs == 1 && not _was_shown("chairs"):
		await _show_rule("chairs", "res://TextFiles/PushInChair.txt", $Chairs,
			"What should you do with chairs?",
			["Push them in when done", "Leave them pulled out", "Stack them up", "Kick them out of the way"], 0)

	if Global.firstCheckout == 1 && not _was_shown("checkout"):
		await _show_rule("checkout", "res://TextFiles/Checkout.txt", $Checkout,
			"How do you properly borrow books?",
			["Check them out at the desk", "Take them without asking", "Borrow them and never return", "Leave them on the desk"], 0)
