extends Area2D

var player: Robot = null

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):	
		#locked_audio.play()
		get_tree().change_scene_to_file("res://scenes/tasks/popups.tscn")

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
