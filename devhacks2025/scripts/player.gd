extends CharacterBody2D


func _enter_tree() -> void:
	if name != "Player":
		set_multiplayer_authority(name.to_int())
		


func _physics_process(delta: float) -> void:
	pass
