extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState.last_level != GameState.LEVELS.LEVEL_3:
		GameState.last_level = GameState.LEVELS.LEVEL_3
		$Landlord.stream = load("res://audio/Landlord/VO_Lord_3.Úvodní řeč.wav")

func _process(delta: float) -> void:
	pass
