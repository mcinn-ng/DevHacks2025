extends Node


@onready var ability_timer: Timer = $AbilityTimer


#every time someone presses and input check for ability 
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	if event.is_action_pressed("use_heavy"):
		#call sprite change 
		var snail_sprite = get_parent().get_node("BodySprite")
		var shell_sprite = get_parent().get_node("BodySprite/ShellSprite")
		snail_sprite.play("Heavy")
		shell_sprite.visible = false
		

		##5,6 8,6
		
		ability_timer.start()  # Start the timer
		
		var adjacent_tiles = get_tiles_in_contact()
		
		for tile_pos in adjacent_tiles:
			if is_tile_breakable(tile_pos):
				destroytile(tile_pos)
			elif is_tile_button(tile_pos):
				press_button(tile_pos)
				

func _on_AbilityTimer_timeout():
	var snail_sprite = get_parent().get_node("BodySprite")
	var shell_sprite = get_parent().get_node("BodySprite/ShellSprite")
	snail_sprite.play("Snail")
	shell_sprite.visible = true
	
func press_button(tile_pos)->void:
	var tilemap = get_parent().get_parent().get_node("TileMap")
	var tilemap2 = get_parent().get_parent().get_node("TileMap/LogicMap")

	# Get current tile data
	var current_source_id = tilemap.get_cell_source_id(0, tile_pos)
	var current_atlas_coords = tilemap.get_cell_atlas_coords(0, tile_pos)
	
	var current_source_id2 = tilemap2.get_cell_source_id(0, tile_pos)
	var current_atlas_coords2 = tilemap2.get_cell_atlas_coords(0, tile_pos)
	#var current_alternative_id = tilemap.get_cell_alternative_tile(0, tile_pos)
	print(current_source_id)
	print(current_atlas_coords)
	# Define the two tiles we want to swap between
	var tile_1 = Vector2i(8, 6)  # First tile in the atlas (adjust as needed)
	var tile_2 = Vector2i(5, 6)  # Second tile in the atlas (adjust as needed)

	# Swap between the two tiles
	var new_atlas_coords = tile_2 #if current_atlas_coords == tile_1 else tile_1
	var new_atlas_coords2 = tile_2 #if current_atlas_coords2 == tile_1 else tile_1

	# Set the new tile at the same position
	tilemap.set_cell(0, tile_pos, current_source_id, new_atlas_coords)
	tilemap2.set_cell(0, tile_pos, current_source_id2, new_atlas_coords2)
	tilemap.set_cell(0, (Vector2i(8,0)), -1)
	

	
	
func is_tile_button(tile_pos) -> bool:
	var logic_map = get_parent().get_parent().get_node("TileMap/LogicMap")
	var tile_data = logic_map.get_cell_tile_data(0,tile_pos)
	
	return tile_data and tile_data.get_custom_data("is_button")
	
	
func is_tile_breakable(tile_pos) -> bool:
	var logic_map = get_parent().get_parent().get_node("TileMap/LogicMap")
	var tile_data = logic_map.get_cell_tile_data(0,tile_pos)
	
	return tile_data and tile_data.get_custom_data("is_breakable")
	
func destroytile(tile_pos) -> void:
	var tile_map = get_parent().get_parent().get_node("TileMap")
	tile_map.set_cell(0, tile_pos, -1)
	

func get_tiles_in_contact() -> Array:
	var tilemap = get_parent().get_parent().get_node("TileMap/LogicMap")
	var tiles = [] 
	
	var collision_shape = $"../CollisionShape2D"
	
	var shape_rect = collision_shape.shape.get_rect()
	var global_scale = collision_shape.get_global_scale()  # Node2D scale, e.g. (2,2)

# Scale the local rect by the parent's global_scale
	var scaled_size = shape_rect.size * global_scale
	var scaled_position = shape_rect.position * global_scale
	
	var scaled_rect = Rect2(scaled_position, scaled_size)
	var player_rect = Rect2(get_parent().global_position + scaled_rect.position, scaled_rect.size)
	print("shape_rect:", scaled_rect)
	print("player_rect:", player_rect)

	# Check the bottom center of the bounding box
	var bottom_center = player_rect.position + Vector2(player_rect.size.x * 0.5, player_rect.size.y)
	# Convert to tile coordinates
	var tile_pos = tilemap.local_to_map(bottom_center)
	print(tile_pos)
	# Check if a tile exists
	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
	
	if tile_data:
		tiles.append(tile_pos)
		print(tile_data)
	return tiles
