extends Node2D

@export var music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.last_level = GameState.LEVELS.LEVEL_2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
