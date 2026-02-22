extends Node

var initialSequenceCompleted = false

var previous_scene_path: String = ""
var previous_room_scene_path: String = ""
var player_return_position: Vector2 = Vector2.ZERO

var player_energy: int = 15

func take_energy(amount: int) -> void:
	GameManager.player_energy = max(GameManager.player_energy - amount, 0)
	if GameManager.player_energy <= 0:
		GameState.reset_game_state()
		GameManager.initialSequenceCompleted = false
		get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")
	
func heal_energy(amount: int) -> void:
	GameManager.player_energy = max(GameManager.player_energy + amount, 0)
