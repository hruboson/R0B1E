extends Area2D

var player_inside = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://scenes/levels/level_1/rooms/room_1.tscn")
