extends Node

const DEFAULT_PORT := 3050
const DEFAULT_HOST_ID := 1


func connect_to_host(address : String, port : int = DEFAULT_PORT) -> Error:
	var multiplayer_peer := ENetMultiplayerPeer.new()
	var error := multiplayer_peer.create_client(address, port)
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = multiplayer_peer
	return error


func setup_server(port : int = DEFAULT_PORT) -> Error:
	var multiplayer_peer := ENetMultiplayerPeer.new()
	var error := multiplayer_peer.create_server(port)
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = multiplayer_peer
	return error


func disconnect_session() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()
