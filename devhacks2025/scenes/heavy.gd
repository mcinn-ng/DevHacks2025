extends Node


@onready var ability_timer: Timer = $AbilityTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass
	
	
#every time someone presses and input check for ability 
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		#call sprite change 
		var snail_sprite = get_parent().get_node("AnimatedSprite2D")
		var shell_sprite = get_parent().get_node("AnimatedSprite2D/AnimatedSprite2D2")
		snail_sprite.play("Heavy")
		shell_sprite.visible = false
		
		ability_timer.start()  # Start the timer
		
		var adjacent_tiles = get_tiles_in_contact()
		
		for tile_pos in adjacent_tiles:
			if is_tile_breakable(tile_pos):
				destroytile(tile_pos)

func _on_ability_timer_timeout():
	var snail_sprite = get_parent().get_node("AnimatedSprite2D")
	var shell_sprite = get_parent().get_node("AnimatedSprite2D/AnimatedSprite2D2")
	snail_sprite.play("Snail")
	shell_sprite.visible = true
	
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
