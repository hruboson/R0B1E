extends Area2D

var player: Robot = null

func _process(delta: float) -> void:
	if player != null:
		$Sprite2D.show()
	else:
		$Sprite2D.hide()

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
