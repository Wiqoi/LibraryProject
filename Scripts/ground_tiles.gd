extends TileMapLayer

func _ready():
	# Array of atlas coordinates to look for
	var target_atlas_coords = [
		Vector2i(14, 9),
		Vector2i(16, 9), 
		Vector2i(15, 9),
		Vector2i(14, 10), 
		Vector2i(15, 10), 
		Vector2i(16, 10),
		Vector2i(11, 13),
		Vector2i(12, 13), 
		Vector2i(13, 13),
		Vector2i(11, 14), 
		Vector2i(12, 14), 
		Vector2i(13, 14)
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
	print("Found ", matching_cells.size(), " matching tiles:")
	Global.studentspawnarea = matching_cells
	Global.studentspawnareacells = matching_cells2
