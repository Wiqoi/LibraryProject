extends HSlider

# Runs once automatically when the slider node loads into the scene
func _ready() -> void:
	# Force set slider to maximum value on game start
	value = max_value
	# Apply the matching max volume immediately
	update_volume(value)

func _on_value_changed(slider_value: float) -> void:
	update_volume(slider_value)

# Reusable volume calculation function
func update_volume(slider_value: float) -> void:
	# Map slider 0~10 range linearly from -80dB (mute) to 0dB (max volume)
	var volume_db = remap(slider_value, min_value, max_value, -80.0, 0.0)
	AudioServer.set_bus_volume_db(0, volume_db)

func _on_resolutions_item_selected(index: int) -> void:
	pass
