extends Area2D

########## NODES ############
@onready var hint: Sprite2D = $Hint
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player: Robot = null

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):	
		audio.play()
		player.show_text("Locked")

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
