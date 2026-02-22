extends Node

var initialSequenceCompleted = false
var previous_scene_path: String = ""
var previous_room_scene_path: String = ""
var player_return_position: Vector2 = Vector2.ZERO
var player_energy: int = 15

func take_energy(amount: int) -> void:
	player_energy = max(player_energy - amount, 0)
	if player_energy <= 0:
		DeathHandler.handle_death()
	
func heal_energy(amount: int) -> void:
	player_energy = max(player_energy + amount, 0)
