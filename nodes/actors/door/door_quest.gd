extends Area2D

########## EXPORTS ###########
@export_multiline var subtitles: String = ""
@export_multiline var subtitles_optional: String = ""
@export var sub_length: float = 3.0
@export var sub_optional_length: float = 3.0
@export var audio_func_name: String

########## NODES ############
@onready var hint: Sprite2D = $Hint

var player: Robot = null

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):
		if player.input_enabled:
			player.init_tenant_quest(subtitles, subtitles_optional, sub_length, sub_optional_length, audio_func_name)

############################
#          SIGNALS         #
############################

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
