extends Area2D

########## EXPORTS ###########
@export var leads_to: PackedScene

var player_inside: bool = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_packed(leads_to)

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
