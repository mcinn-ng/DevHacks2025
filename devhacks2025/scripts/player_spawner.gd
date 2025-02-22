class_name PlayerSpawner
extends MultiplayerSpawner


const PLAYER = preload("res://scenes/player.tscn")
const WALL_BREAK_COMPONENT = preload("res://components/wall_break_component.tscn")


enum Component {
	DOUBLE_JUMP,
	CROUCH,
	WALL_BREAK,
	HEAVY
}


@export var player_colors : Array[Color] = [ 0x4a70ffff, 0xcc00e3ff, 0xff9757ff, 0x189950ff ]
@export var player_spawn_point : Vector2 = Vector2.ZERO

# expects Array[Array[Component]]
var player_components : Array[Array] = [[ Component.DOUBLE_JUMP ], [ Component.CROUCH ], [ Component.WALL_BREAK ], [ Component.HEAVY ]]


var _available_components : Array[Array] = player_components

var _color_index : int = 0
var _players := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_player
	if multiplayer.is_server():
		setup_as_host()


func _exit_tree() -> void:
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.disconnect(_on_peer_connected)
	if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)


func setup_as_host() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


#don't use this function. Use the `spawn()` function instead
func _spawn_player(data : Dictionary) -> Node:
	var player = PLAYER.instantiate()
	
	if data.has("id"):
		player.name = str(data.id)
	if data.has("spawn_point"):
		player.position = data.spawn_point
	if data.has("color"):
		player.color = data.color
	if data.has("components"):
		_apply_components(player, data.components)
	
	var wall_break_component = load("res://components/wall_break_component.tscn").instantiate()
	player.add_child(wall_break_component)
	
	return player


func _apply_components(player : CharacterBody2D, components : Array) -> void:
	for component_index in components:
		match Component.values()[component_index]:
			Component.DOUBLE_JUMP:
				var jump : JumpComponent = player.get_node("JumpComponent")
				jump.double_jump = true
			Component.CROUCH:
				#TODO: Implement crouch
				pass
			Component.WALL_BREAK:
				var wall_break : WallBreakComponent = WALL_BREAK_COMPONENT.instantiate()
				player.add_child(wall_break)
			Component.HEAVY:
				#TODO: Implement heavy
				pass


func _on_peer_connected(id : int) -> void:
	var spawn_data := {
		"id" : id,
		"color" : _get_color(_color_index),
		"spawn_point" : player_spawn_point,
	}
	if _players.size() < player_components.size():
		spawn_data["components"] = player_components[_players.size()]
	_color_index += 1
	
	var player := spawn(spawn_data)
	_players[id] = player


func _on_peer_disconnected(id : int) -> void:
	if _players.has(id):
		if is_instance_valid(_players[id]):
			_players[id].queue_free()
		_players.erase(id)


func _get_color(index : int) -> Color:
	if index < player_colors.size():
		return player_colors[index]
	else:
		return _random_color()


func _random_color() -> Color:
	return Color(randf(), randf(),randf())
