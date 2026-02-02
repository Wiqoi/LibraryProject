extends TileMapLayer

func _ready():
	# Array of atlas coordinates to look for
	var target_atlas_coords = [
		Vector2i(1, 10),
		Vector2i(2, 10),
		Vector2i(1, 11),
		Vector2i(2, 11),
		Vector2i(4, 10),
		Vector2i(4, 11),
		Vector2i(6, 10),
		Vector2i(7, 10),
		Vector2i(6, 11),
		Vector2i(7, 11),
		Vector2i(9, 10),
		Vector2i(9, 11),
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
	
	var used_cells = get_used_cells()
	
	for cell in used_cells:
		var atlas_coords = get_cell_atlas_coords(cell)
		
		# Check if this atlas_coords is in our target array
		if target_atlas_coords.has(atlas_coords):
			matching_cells.append(to_global(map_to_local(cell)))
	
	Global.bookdropcoords = matching_cells
	for cells in matching_cells:
		if cells in Global.studentspawnarea:
			Global.studentspawnarea.erase(cells)
