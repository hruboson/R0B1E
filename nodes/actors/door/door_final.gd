extends Area2D

########## NODES ############
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var boss_audio: AudioStreamPlayer2D = $Boss

signal transition_requested

var player: Robot = null
var transitioning := false

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):
		player.show_text("Hm, tak jste až tady - snad bude příští generace mít větší zlepšení, vy se už ale zlepšit nestihnete.", 23)
		emit_signal("transition_requested")
		$Boss.play()
		await get_tree().create_timer(23.0).timeout
		GameManager.initialSequenceCompleted = false
		get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
