extends Area2D

########## EXPORTS ###########
@export_file("*.tscn") var leads_to: String
@export var inward: bool = false
@export var pop_room: bool = false

var player: Robot = null

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):	
		var scene: PackedScene = load(leads_to)	
		$AnimatedSprite2D.play("default")
		
		player.play_fade("fade_in")
		if !inward:
			await player.walk_in()
		else:
			await player.walk_out()
			
		if pop_room and GameManager.previous_scene_path != "":
			get_tree().change_scene_to_file(GameManager.previous_scene_path)
		else:
			GameManager.previous_scene_path = get_tree().current_scene.scene_file_path
			GameManager.player_return_position = player.global_position
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
