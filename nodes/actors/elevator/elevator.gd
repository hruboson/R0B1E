extends Node2D

########## EXPORTS ###########
@export var leads_to: PackedScene

########## NODES ###########
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

###########################
# 		PROPERTIES		  #
###########################
var player_inside: bool = false

func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		close_doors(leads_to)

func open_doors() -> void:
	pass
	
#####
# @func close_doors
# @param leads_to_direct: PackedScene (optional)
#		Overrides the default leads_to variable. This parameter is only used in menu so far.
func close_doors(leads_to_direct: PackedScene) -> void:
	# TODO get the timing right
	if(leads_to_direct):
		transition_to(leads_to_direct)
	else:
		transition_to(leads_to)
	return 
	
	audio.play()
	await get_tree().create_timer(.5).timeout
	
	var tween_front = get_tree().create_tween()
	tween_front.tween_property($LeftFrontDoor, "position:x", $LeftFrontDoor.position.x + 80, 2.5) # object, property, value, time
	tween_front.parallel().tween_property($RightFrontDoor, "position:x", $RightFrontDoor.position.x - 80, 2.5)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_back = get_tree().create_tween()
	tween_back.tween_property($RightBackDoor, "position:x", $RightBackDoor.position.x - 50, 2.5)
	tween_back.parallel().tween_property($LeftBackDoor, "position:x", $LeftBackDoor.position.x + 50, 2.5)
	
	await tween_back.finished
	await get_tree().create_timer(.5).timeout
	
	var tween_elevator = get_tree().create_tween()
	tween_elevator.tween_property($BG, "position:y", $BG.position.y - 500, 7.0)
	tween_elevator.parallel().tween_property($RightBackDoor, "position:y", $RightBackDoor.position.y - 500, 7.0)
	tween_elevator.parallel().tween_property($LeftBackDoor, "position:y", $LeftBackDoor.position.y - 500, 7.0)
	
	await get_tree().create_timer(7.0).timeout
	audio.stop()
	
	if(leads_to_direct):
		transition_to(leads_to_direct)
	else:
		transition_to(leads_to)
	
func transition_to(leads_to: PackedScene) -> void:
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
