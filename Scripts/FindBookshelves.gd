extends TileMapLayer

func _ready():
	await get_tree().create_timer(0.1).timeout
	var target_atlas_coords = [
		Vector2i(12, 70),  
		Vector2i(11, 70),
		Vector2i(10, 70),
		Vector2i(13, 70),
		Vector2i(14, 70),
		Vector2i(15, 70),
		Vector2i(12, 73),  
		Vector2i(11, 73),
		Vector2i(10, 73),
		Vector2i(13, 73),
		Vector2i(14, 73),
		Vector2i(15, 73),
		Vector2i(12, 68),  
		Vector2i(11, 68),
		Vector2i(10, 68),
		Vector2i(13, 68),
		Vector2i(14, 68),
		Vector2i(15, 68),
		Vector2i(12, 71),  
		Vector2i(11, 71),
		Vector2i(10, 71),
		Vector2i(13, 71),
		Vector2i(14, 71),
		Vector2i(15, 71),
		Vector2i(12, 72),  
		Vector2i(11, 72),
		Vector2i(10, 72),
		Vector2i(13, 72),
		Vector2i(14, 72),
		Vector2i(15, 72),
		Vector2i(12, 69),  
		Vector2i(11, 69),
		Vector2i(10, 69),
		Vector2i(13, 69),
		Vector2i(14, 69),
		Vector2i(15, 69)
	]
	
	var matching_cells = []
	var matching_cells2 = []
	
	var used_cells = get_used_cells()
	
	for cell in used_cells:
		var atlas_coords = get_cell_atlas_coords(cell)
		
		if target_atlas_coords.has(atlas_coords):
			matching_cells.append(to_global(map_to_local(cell)))
			matching_cells2.append(cell)
	Global.bookdropcoords = matching_cells
	for cells in matching_cells:
		if cells in Global.studentspawnarea:
			Global.studentspawnarea.erase(cells)
	for cells in matching_cells2:
		if cells in Global.studentspawnareacells:
			Global.studentspawnareacells.erase(cells)
	Global.studentPathFinding = matching_cells2
