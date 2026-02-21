extends Area2D

########## EXPORTS ###########
@export_file("*.tscn") var leads_to: String
@export var inward: bool = false

var player: Robot = null

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):	
		var scene: PackedScene = load(leads_to)	
		
		player.play_fade("fade_in")
		if !inward:
			await player.walk_in()
		else:
			await player.walk_out()
			
		get_tree().change_scene_to_packed(scene)

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
