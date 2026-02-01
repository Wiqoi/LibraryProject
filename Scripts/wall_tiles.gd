extends TileMapLayer

func _ready():
	await get_tree().create_timer(1.0).timeout
	var target_atlas_coords = [
		Vector2i(5, 0),
		Vector2i(6, 0),
		Vector2i(7, 0),
		Vector2i(8, 0),
		Vector2i(5, 1),
		Vector2i(6, 1),
		Vector2i(5, 1),
		Vector2i(7, 1),
		Vector2i(8, 1),
		Vector2i(9, 1),
		Vector2i(10, 1),
		Vector2i(11, 1),
		Vector2i(13, 1),
		Vector2i(11, 2),
		Vector2i(13, 2),
		Vector2i(5, 2),
		Vector2i(6, 2),
		Vector2i(11, 3),
		Vector2i(11, 3),
		Vector2i(11, 3)
	]
	
	var matching_cells = []
	
	var used_cells = get_used_cells()
	
	for cell in used_cells:
		var atlas_coords = get_cell_atlas_coords(cell)
		
		# Check if this atlas_coords is in our target array
		if target_atlas_coords.has(atlas_coords):
			matching_cells.append(to_global(map_to_local(cell)))
	for cells in matching_cells:
		if cells in Global.studentspawnarea:
			Global.studentspawnarea.erase(cells)
