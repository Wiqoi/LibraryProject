extends TileMapLayer

func _ready():
	# Array of atlas coordinates to look for
	var target_atlas_coords = [
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
	
	print("Found ", matching_cells.size(), " matching tiles:")
	Global.bookdropcoords = matching_cells
