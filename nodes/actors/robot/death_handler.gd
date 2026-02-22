extends Node

var _death_pending: bool = false

func handle_death() -> void:
	if _death_pending:
		return
	
	_death_pending = true
	call_deferred("_execute_death")

func _execute_death():
	# Prevent multiple death calls
	if not _death_pending:
		return
	
	GameState.reset_game_state()
	GameManager.initialSequenceCompleted = false
	GameManager.player_energy = 15
	get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")
