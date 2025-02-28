extends Area2D


@export var physics_object : PhysicsBody2D


var nearby_players : Array[Player] = [] : set = set_nearby_players


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_authority(MultiplayerManager.DEFAULT_HOST_ID)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_nearby_players(list : Array[Player]) -> void:
	nearby_players = list
	_update_physics_authority()


@rpc("any_peer", "reliable", "call_local")
func _set_authority(peer_id : int) -> void:
	physics_object.set_multiplayer_authority(peer_id)


func _update_physics_authority() -> void:
	if nearby_players.size() == 1:
		_set_authority.rpc(nearby_players.front().get_multiplayer_authority())
	else:
		_set_authority.rpc(MultiplayerManager.DEFAULT_HOST_ID)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if not is_multiplayer_authority():
		#return
	if body is Player:
		nearby_players.append(body)
		_update_physics_authority()


func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if not is_multiplayer_authority():
		#return
	if body is Player:
		nearby_players.erase(body)
		_update_physics_authority()
