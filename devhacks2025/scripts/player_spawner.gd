class_name PlayerSpawner
extends MultiplayerSpawner


signal spawn_point_updated


const PLAYER = preload("res://scenes/player.tscn")


@export var player_colors : Array[Color] = [ 0x4a70ffff, 0xcc00e3ff, 0xff9757ff, 0x189950ff ]
@export var player_spawn_point : Vector2 = Vector2.ZERO : set = set_spawn_point


var _peer_indexes : Array[int] = [0, 1, 2, 3]
var _players := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_player
	if MultiplayerManager.hosting:
		setup_as_host()


func _exit_tree() -> void:
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.disconnect(_on_peer_connected)
	if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)


func setup_as_host() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	_on_peer_connected(MultiplayerManager.DEFAULT_HOST_ID)


func set_player_components(id : int, components : Array[int]) -> void:
	if not _players.has(str(id)):
		return
	
	var typed_components : Array[Player.Component] = []
	typed_components.append_array(components.map(func(x : int) -> Player.Component: return Player.Component.values()[x]))
	
	var player : Player = _players[str(id)]
	player.set_components.rpc(typed_components)


func set_spawn_point(point : Vector2) -> void:
	player_spawn_point = point
	
	if is_multiplayer_authority():
		for player in _players.values():
			if player.player_character.is_multiplayer_authority():
				player.player_character.respawn(player_spawn_point)
			else:
				player.player_character.respawn.rpc_id(player.player_character.get_multiplayer_authority(), player_spawn_point)
	
	spawn_point_updated.emit()


#don't use this function. Use the `spawn()` function instead
func _spawn_player(data : Dictionary) -> Node:
	var player = PLAYER.instantiate()
	
	if data.has("id"):
		player.name = str(data.id)
	if data.has("spawn_point"):
		player.position = data.spawn_point
	if data.has("color"):
		player.color = data.color
	
	var wall_break_component = load("res://components/wall_break_component.tscn").instantiate()
	player.add_child(wall_break_component)
	
	return player



func _on_peer_connected(id : int) -> void:
	if not player_spawn_point:
		await spawn_point_updated
	
	var peer_index : int = _peer_indexes.pop_front()
	if _peer_indexes.is_empty():
		_peer_indexes.append(peer_index + 1)
	
	var spawn_data := {
		"id" : id,
		"color" : _get_color(peer_index),
		"spawn_point" : player_spawn_point,
	}
	
	var player := spawn(spawn_data)
	_players[str(id)] = SessionPeer.new(
		id,
		peer_index,
		player
	)


func _on_peer_disconnected(id : int) -> void:
	if _players.has(str(id)):
		var session_peer : SessionPeer = _players[str(id)]
		if is_instance_valid(session_peer.player_character):
			session_peer.player_character.queue_free()
		_peer_indexes.push_front(session_peer.peer_index)
		_players.erase(str(id))


func _get_color(index : int) -> Color:
	if index < player_colors.size():
		return player_colors[index]
	else:
		return _random_color()


func _random_color() -> Color:
	return Color(randf(), randf(),randf())


class SessionPeer:
	var id : int
	var peer_index : int
	var player_character : CharacterBody2D
	
	@warning_ignore("shadowed_variable")
	func _init(peer_id : int, peer_index : int, character : CharacterBody2D) -> void:
		self.id = peer_id
		self.peer_index = peer_index
		self.player_character = character
