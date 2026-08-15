extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Prevent rule popups/quizzes from firing during the debug pass
	for key in ["food", "sanitize", "books", "backpack", "fighting", "noise", "running", "chairs", "checkout"]:
		Global.rules_shown[key] = true

	# Complete every available event; wait a frame between passes so
	# phase transitions (fight start, door gate) can happen in _process
	for pass_idx in 40:
		var completed_any = false
		for obj in get_tree().get_nodes_in_group("interactables"):
			if is_instance_valid(obj) and obj.is_available():
				completed_any = true
				_force_complete(obj)
		if not completed_any:
			break
		await get_tree().process_frame

func _force_complete(obj) -> void:
	if obj.has_method("start_pickup"):
		obj.start_pickup()
	elif obj.has_method("start_stow"):
		obj.start_stow()
	elif obj.has_method("start_interaction"):
		obj.start_interaction()

	if obj.has_method("_complete_pickup"):
		obj._complete_pickup()
	elif obj.has_method("_complete_stow"):
		obj._complete_stow()
	elif obj.has_method("_complete_interaction"):
		obj._complete_interaction()
