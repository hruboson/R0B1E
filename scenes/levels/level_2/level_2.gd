extends Node2D

@export var music: AudioStream

func _ready() -> void:
	GameState.last_level = GameState.LEVELS.LEVEL_2
	await get_tree().create_timer(5.0).timeout
