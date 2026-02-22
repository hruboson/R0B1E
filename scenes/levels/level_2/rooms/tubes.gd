extends Area2D

var player: Robot = null

@export var level_key: String
@export var quest_key: String

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact") and !GameState.levels_state[level_key][quest_key]:	
		GameManager.previous_scene_path = get_tree().current_scene.scene_file_path
		GameManager.player_return_position = player.global_position	
		GameState.level_key = level_key
		GameState.quest_key = quest_key
		player.take_energy(1)
		get_tree().change_scene_to_file("res://scenes/tasks/tubes/tubes.tscn")

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
