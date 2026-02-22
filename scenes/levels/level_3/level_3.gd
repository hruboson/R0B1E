extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState.last_level != GameState.LEVELS.LEVEL_3:
		GameState.last_level = GameState.LEVELS.LEVEL_3
		$AudioStreamPlayer2D.play()

func _process(delta: float) -> void:
	pass
