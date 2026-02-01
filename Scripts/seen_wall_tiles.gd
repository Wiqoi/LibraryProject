extends TileMapLayer

func _ready():
	await get_tree().create_timer(1.0).timeout
	var target_atlas_coords = [
		Vector2i(0, 17),
		Vector2i(1, 17),
		Vector2i(2, 17),
		Vector2i(0, 18),
		Vector2i(1, 18),
		Vector2i(2, 18),
	]
	
	var matching_cells = []
	var matching_cells2 = []
	
	var used_cells = get_used_cells()
	
	for cell in used_cells:
		var atlas_coords = get_cell_atlas_coords(cell)
		
		# Check if this atlas_coords is in our target array
		if target_atlas_coords.has(atlas_coords):
			matching_cells.append(to_global(map_to_local(cell)))
			matching_cells2.append(cell)
	for cells in matching_cells:
		if cells in Global.studentspawnarea:
			Global.studentspawnarea.erase(cells)
	for cells in matching_cells2:
		if cells in Global.studentspawnareacells:
			Global.studentspawnareacells.erase(cells)
	Global.studentPathFinding = matching_cells2
