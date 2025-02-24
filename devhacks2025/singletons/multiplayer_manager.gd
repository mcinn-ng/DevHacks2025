extends Node


signal peer_connected(id : int)
signal peer_disconnected(id : int)


const DEFAULT_PORT := 3050
const DEFAULT_HOST_ID := 1


@export var player_indexes : Dictionary = {}

# Can be overridden using command line arg "--address"
var client_default_address := ""


# Used to keep track of available player indexes
# example: if there are 4 players and player 2 disconnects, the next player to connect becomes player 2 rather than player 5
# shifting player indexes is not currently implemented because joining mid-game becomes complicated
var _available_indexes : Array[int] = [ 0 ]


func _enter_tree() -> void:
	Util.connect_to_signal(multiplayer.peer_connected, _on_peer_connected, CONNECT_DEFERRED)
	Util.connect_to_signal(multiplayer.peer_disconnected, _on_peer_connected, CONNECT_DEFERRED)


func _exit_tree() -> void:
	Util.disconnect_from_signal(multiplayer.peer_connected, _on_peer_connected)
	Util.disconnect_from_signal(multiplayer.peer_disconnected, _on_peer_connected)


func connect_to_host(address : String, port : int = DEFAULT_PORT) -> Error:
	disconnect_session()
	
	var multiplayer_peer := ENetMultiplayerPeer.new()
	var error := multiplayer_peer.create_client(address, port)
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = multiplayer_peer
	return error


func setup_server(port : int = DEFAULT_PORT) -> Error:
	disconnect_session()
	
	_reset_player_indexes()
	var multiplayer_peer := ENetMultiplayerPeer.new()
	var error := multiplayer_peer.create_server(port)
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = multiplayer_peer
		_on_peer_connected(1)
	return error


func disconnect_session() -> void:
	if is_active():
		multiplayer.multiplayer_peer.close()


func is_active() -> bool:
	return multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED


func is_server() -> bool:
	return is_active() and multiplayer.is_server()


func _reset_player_indexes() -> void:
	player_indexes.clear()
	_available_indexes = [ 0 ]


#returns -1 if no such peer id is found
func get_player_index(peer_id : int) -> int:
	var str_id := str(peer_id)
	return player_indexes[str_id] if player_indexes.has(str_id) else -1

#returns 0 if no such index is found
func get_peer_id(player_index : int) -> int:
	var peer_id = player_indexes.find_key(player_index)
	return 0 if peer_id == null else peer_id


func _claim_next_player_index() -> int:
	var index : int = _available_indexes.pop_back()
	
	if _available_indexes.is_empty():
		# as the highest available player index is always at index 0, not checking the indexes is safe
		_available_indexes.append(index + 1)
	
	return index


func _release_player_index(index : int) -> void:
	_available_indexes.append(index)


func _on_peer_connected(id : int) -> void:
	if is_server():
		var player_index : int = _claim_next_player_index()
		player_indexes[str(id)] = player_index
	
	peer_connected.emit(id)


func _on_peer_disconnected(id : int) -> void:
	
	if is_server():
		var str_id := str(id)
		
		if player_indexes.has(str_id):
			var player_index = player_indexes[str_id]
		
			if player_index < 0:
				_potential_usage_error("Peer disconnected with a player index < 0.")
			else:
				_release_player_index(player_index)
		else:
			_potential_usage_error("Peer disconnected without being assigned a player index.")
	
	peer_disconnected.emit(id)

#incorrect usage involves modifying private variables (starting in "_") or inputting invalid data
func _potential_usage_error(message : String) -> void:
	push_error(message, " Check for incorrect usage of the multiplayer manager.")
