extends MenuBar

var lines: Array = []
var loaded_path: String = ""

# Progress counters shown per objective line, keyed by the objectives file
var counters_by_level = {
	"Level1Objectives.txt": [
		["sanitize_done", "sanitize_total"],
		["cubby_done", "cubby_total"],
		["fighting_done", "fighting_total"],
		["enter_done", "enter_total"],
	],
	"Level2Objectives.txt": [
		["books_done", "books_total"],
		["shouting_done", "shouting_total"],
		["running_done", "running_total"],
		["food_done", "food_total"],
	],
}

func _load_objectives() -> void:
	lines.clear()
	var f = FileAccess.open(Global.Objectives, FileAccess.READ)
	if f == null:
		return
	while not f.eof_reached():
		var line = f.get_line().strip_edges()
		if line != "":
			lines.append(line)

func _process(delta: float) -> void:
	# Reload objectives file only when the path changes (level script sets it after HUD _ready)
	if Global.Objectives != loaded_path:
		loaded_path = Global.Objectives
		_load_objectives()

	var labels = [$"ObjectivesBox/Objective 1", $"ObjectivesBox/Objective 2", $"ObjectivesBox/Objective 3", $"ObjectivesBox/Objective 4"]
	var level_name = Global.Objectives.get_file()
	var counters: Array = counters_by_level.get(level_name, [])

	var idx = 0
	for i in lines.size():
		# Skip objectives not yet revealed or already completed
		if i < Global.objectives_revealed.size() and not Global.objectives_revealed[i]:
			continue
		if i < Global.objectives_done.size() and Global.objectives_done[i]:
			continue
		if idx < labels.size():
			var line_text = " - " + lines[i]
			if i < counters.size():
				line_text += " (" + str(Global.get(counters[i][0])) + "/" + str(Global.get(counters[i][1])) + ")"
			labels[idx].text = line_text
			idx += 1
	# Clear remaining slots
	while idx < labels.size():
		labels[idx].text = ""
		idx += 1
