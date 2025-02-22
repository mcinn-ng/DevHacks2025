extends Node

@export var player1 : Array[Player.Component] = []
@export var player2 : Array[Player.Component] = []
@export var player3 : Array[Player.Component] = []
@export var player4 : Array[Player.Component] = []

var _components : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_components = [
		player1,
		player2,
		player3,
		player4,
	]
	_components.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_player_components(player_index : int) -> Array[Player.Component]:
	if player_index < 0 or player_index > _components.size():
		return []
	else:
		return _components[player_index]
