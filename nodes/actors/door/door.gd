extends Area2D

########## EXPORTS ###########
@export var leads_to: PackedScene

var player: Robot = null

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):
		await player.walk_in()
		get_tree().change_scene_to_packed(leads_to)

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
