extends Control

var _quiz_answered := false
var _quiz_picked := 0
var _quiz_buttons: Array = []
var _base_positions: Dictionary = {}
var _showing := false

const RULES := {
	"food": {"file": "res://TextFiles/CollectFood.txt", "question": "Can we eat in the library?", "answers": ["No. Food can make a mess.", "Yes, anywhere.", "Only on books.", "Only while running."]},
	"sanitize": {"file": "res://TextFiles/SanitizeHands.txt", "question": "Why do we clean our hands?", "answers": ["To keep books clean.", "To make noise.", "To run faster.", "To hide dirt."]},
	"books": {"file": "res://TextFiles/BookOrganization.txt", "question": "Where do books go?", "answers": ["On the right shelf.", "On the floor.", "In the trash.", "Behind a chair."]},
	"backpack": {"file": "res://TextFiles/PlaceBackBackPack.txt", "question": "Where do bags go?", "answers": ["In the cubbies.", "On the floor.", "In the doorway.", "On a table."]},
	"fighting": {"file": "res://TextFiles/NoFighting.txt", "question": "What should we do when we are upset?", "answers": ["Use calm words.", "Hit someone.", "Yell louder.", "Push someone."]},
	"noise": {"file": "res://TextFiles/NoLoudNoises.txt", "question": "How should we talk in the library?", "answers": ["Use a quiet voice.", "Shout.", "Sing loudly.", "Bang on tables."]},
	"running": {"file": "res://TextFiles/Running Around.txt", "question": "How should we move in the library?", "answers": ["Walk.", "Run fast.", "Jump on chairs.", "Slide on the floor."]},
	"chairs": {"file": "res://TextFiles/PushInChair.txt", "question": "What do we do with a chair?", "answers": ["Push it in.", "Leave it out.", "Kick it.", "Stand on it."]},
	"checkout": {"file": "res://TextFiles/Checkout.txt", "question": "What do we do before taking a book home?", "answers": ["Check it out.", "Hide it.", "Take it quickly.", "Leave it on the floor."]},
	"lineup": {"file": "res://TextFiles/LineUp.txt", "question": "How do we get ready to leave?", "answers": ["Stand in a quiet line.", "Run around.", "Shout loudly.", "Hide under a desk."]},
	"leave": {"file": "res://TextFiles/LetKidsLeave.txt", "question": "How do we leave the library?", "answers": ["Walk out quietly.", "Run and yell.", "Leave a mess.", "Push past friends."]},
}


func _ready() -> void:
	_quiz_buttons = [$QuizPanel/AnswerA, $QuizPanel/AnswerB, $QuizPanel/AnswerC, $QuizPanel/AnswerD]
	for i in _quiz_buttons.size():
		_quiz_buttons[i].pressed.connect(_on_answer.bind(i))


func _on_answer(picked: int) -> void:
	_quiz_answered = true
	_quiz_picked = picked


func _input(event: InputEvent) -> void:
	# Keyboard fallback so the quiz is always answerable (1-4 or A-D),
	# even if mouse input is unavailable (e.g. some web builds).
	if not visible or not $QuizPanel.visible:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var idx := -1
	match event.keycode:
		KEY_1, KEY_KP_1, KEY_A: idx = 0
		KEY_2, KEY_KP_2, KEY_B: idx = 1
		KEY_3, KEY_KP_3, KEY_C: idx = 2
		KEY_4, KEY_KP_4, KEY_D: idx = 3
	if idx >= 0 and idx < _quiz_buttons.size() and not _quiz_buttons[idx].disabled:
		_on_answer(idx)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if _showing or Global.pending_rules.is_empty():
		return
	var key := Global.take_next_rule()
	if key != "":
		await _show_rule(key)


func _show_rule(key: String) -> void:
	_showing = true
	var rule: Dictionary = RULES[key]
	var poster := _poster_for(key)
	var f := FileAccess.open(rule.file, FileAccess.READ)
	Global.givenText = f.get_line() if f != null else ""
	if poster:
		poster.visible = true
	$QuizPanel.visible = true
	visible = true
	get_tree().paused = true

	var page: Array = [$ColorRect, $RichTextLabel, $QuizPanel]
	if poster:
		page.append(poster)
	for node in page:
		_swing_down(node)

	var attempts := await _run_quiz(rule.question, rule.answers)
	await _drop_out_page(page).finished

	for node in page:
		node.position = _get_base(node)
	if poster:
		poster.visible = false
	$QuizPanel.visible = false
	visible = false
	get_tree().paused = false
	Global.finish_quiz(attempts)
	_showing = false


func _run_quiz(question: String, answers: Array) -> int:
	$QuizPanel/QuizQuestion.text = question
	var order: Array = [0, 1, 2, 3]
	order.shuffle()
	var correct_button := order.find(0)
	for i in _quiz_buttons.size():
		_quiz_buttons[i].text = answers[order[i]]
		_quiz_buttons[i].modulate = Color.WHITE
		_quiz_buttons[i].disabled = false

	var attempts := 0
	while true:
		_quiz_answered = false
		# Fail-safe: never leave the game paused waiting forever. If the
		# player does not answer within the limit, auto-resolve the quiz.
		var wait_start := Time.get_ticks_msec()
		while not _quiz_answered:
			await get_tree().process_frame
			if Time.get_ticks_msec() - wait_start > 45000:
				return attempts + 1
		attempts += 1
		if _quiz_picked == correct_button:
			return attempts
		if _quiz_picked < 0 or _quiz_picked >= _quiz_buttons.size():
			return attempts
		_quiz_buttons[_quiz_picked].modulate = Color.RED
		_quiz_buttons[_quiz_picked].disabled = true
		await get_tree().create_timer(0.3).timeout
	return attempts


func _poster_for(key: String) -> Control:
	var names := {
		"food": "Food", "sanitize": "Sanitize", "books": "Books",
		"backpack": "Backpack", "fighting": "Fighting", "noise": "Noise",
		"running": "Running", "chairs": "Chairs", "checkout": "Checkout",
	}
	if not names.has(key):
		return null
	return get_node(names[key]) as Control


func _get_base(node: Control) -> Vector2:
	if not _base_positions.has(node):
		_base_positions[node] = node.position
	return _base_positions[node]


func _swing_down(node: Control) -> void:
	var base := _get_base(node)
	node.position = base + Vector2(0, -40)
	create_tween().tween_property(node, "position", base, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _drop_out_page(nodes: Array) -> Tween:
	var tween := create_tween()
	tween.set_parallel(true)
	for node in nodes:
		tween.tween_property(node, "position", _get_base(node) + Vector2(0, 800), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return tween
