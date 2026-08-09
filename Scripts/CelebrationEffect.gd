extends Control

func _ready() -> void:
	# Float up and fade out at the position set by the caller
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.2).set_ease(Tween.EASE_IN).set_delay(0.3)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.3).set_ease(Tween.EASE_OUT)

	tween.finished.connect(queue_free)
