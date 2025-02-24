extends Node

@export var player1 : Array[Player.Component] = []
@export var player2 : Array[Player.Component] = []
@export var player3 : Array[Player.Component] = []
@export var player4 : Array[Player.Component] = []

var _components : Array : get = get_components

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_components_array()


func get_components() -> Array:
	_update_components_array()
	return _components


func get_player_components(player_index : int) -> Array[Player.Component]:
	if player_index < 0 or player_index >= _components.size():
		return []
	else:
		return _components[player_index]


func _update_components_array() -> void:
	_components = [
		player1,
		player2,
		player3,
		player4,
	]
