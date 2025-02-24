class_name PlayerSpawner
extends MultiplayerSpawner


signal spawn_point_updated


const PLAYER = preload("res://scenes/player.tscn")

@export var auto_spawn_players : bool = false
@export var player_colors : Array[Color] = [ 0x4a70ffff, 0xcc00e3ff, 0xff9757ff, 0x189950ff ]
@export var player_spawn_point : Vector2 = Vector2.ZERO : set = set_spawn_point
@export var player_components : Array = [] : set = set_player_components

# player_index -> Player (character)
var _player_characters : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_player
	if MultiplayerManager.is_server():
		setup_as_host()


func _exit_tree() -> void:
	Util.disconnect_from_signal(MultiplayerManager.peer_connected, _on_peer_connected)
	Util.disconnect_from_signal(MultiplayerManager.peer_disconnected, _on_peer_disconnected)


func setup_as_host() -> void:
	Util.connect_to_signal(MultiplayerManager.peer_connected, _on_peer_connected)
	Util.connect_to_signal(MultiplayerManager.peer_disconnected, _on_peer_disconnected)
	
	_on_peer_connected(MultiplayerManager.DEFAULT_HOST_ID)


func set_spawn_point(point : Vector2) -> void:
	player_spawn_point = point
	
	if is_multiplayer_authority():
		for player in _player_characters.values():
			if player.is_multiplayer_authority():
				player.respawn(player_spawn_point)
			else:
				player.respawn.rpc_id(player.get_multiplayer_authority(), player_spawn_point)
	
	spawn_point_updated.emit()


func set_player_components(components : Array):
	player_components = components
	for player : Player in _player_characters.values():
		if player.player_index >= 0 and player.player_index <= components.size():
			player.components = components[player.player_index]


func has_player_character(peer_id : int) -> bool:
	return str(peer_id) in _player_characters.keys()


func get_player_character_by_id(peer_id : int) -> Player:
	return get_player_character_by_index(MultiplayerManager.get_player_index(peer_id))


func get_player_character_by_index(player_index : int) -> Player:
	var str_index := str(player_index)
	if _player_characters.has(str_index):
		return _player_characters[str_index]
	else:
		return null


#don't use this function. Use the `spawn()` function instead
func _spawn_player(data : Dictionary) -> Player:
	var player : Player = PLAYER.instantiate()
	
	player.name = str(data.id)
	player.position = data.spawn_point
	player.color = data.color
	player.player_index = data.player_index
	player.set_multiplayer_authority(data.id)
	
	_player_characters[str(player.player_index)] = player
	
	return player


func _spawn_player_for_each_peer() -> void:
	var peers := multiplayer.get_peers()
	var peers_without_character := Array(peers).filter(
		func(id : int) -> bool:
			return not has_player_character(id)
	)
	
	for peer in peers_without_character:
		_spawn_player_for_peer(peer)


func _spawn_player_for_peer(peer_id : int) -> Player:
	var player_index : int = MultiplayerManager.get_player_index(peer_id)
	
	var spawn_data := {
		"id" : peer_id,
		"player_index" : player_index,
		"color" : _get_color(player_index),
		"spawn_point" : player_spawn_point,
	}
	
	var player : Player = spawn(spawn_data)
	
	return player

@rpc("authority", "call_local", "reliable")
func _despawn_player(peer_id : int) -> void:
	var str_index := str(MultiplayerManager.get_player_index(peer_id))
	if _player_characters.has(str_index):
		var character : Player = _player_characters[str_index]
		if is_instance_valid(character):
			character.queue_free()
		_player_characters.erase(str_index)


func _on_peer_connected(id : int) -> void:
	if auto_spawn_players:
		_spawn_player_for_peer(id)


func _on_peer_disconnected(id : int) -> void:
	if MultiplayerManager.is_server():
		_despawn_player.rpc(id)


func _get_color(index : int) -> Color:
	if index < player_colors.size():
		return player_colors[index]
	else:
		return _random_color()


func _random_color() -> Color:
	return Color(randf(), randf(),randf())
