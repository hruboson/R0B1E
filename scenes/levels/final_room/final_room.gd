extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

var transitioning := false

func _ready():
	# Start fully visible (normal brightness)
	canvas_modulate.color = Color(1, 1, 1, 1)
	AudioManager.stop_ambience()

	# Connect all doors automatically
	for door in get_tree().get_nodes_in_group("doors"):
		door.transition_requested.connect(_on_door_final_transition_requested)

func start_fade():
	var tween = create_tween()

	tween.tween_property(canvas_modulate, "color", Color(0, 0, 0, 1), 7.0)
	await tween.finished


func _on_door_final_transition_requested() -> void:
	if transitioning:
		return

	transitioning = true
	start_fade()
