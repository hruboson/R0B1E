extends Node2D

########## EXPORTS ###########
@export var leads_to: PackedScene
@export var is_closed: bool = false

########## NODES ###########
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

###########################
# 		PROPERTIES		  #
###########################
var player: Robot = null

const len_from_center_back: int = 50
const len_from_center_front: int = 80

func _ready() -> void:
	$BG.play("empty")
	if is_closed:
		$LeftBackDoor.position.x += len_from_center_back
		$RightBackDoor.position.x -= len_from_center_back
		$LeftFrontDoor.position.x += len_from_center_front
		$RightFrontDoor.position.x -= len_from_center_front

func _process(delta):
	if player != null and Input.is_action_just_pressed("interact"):
		player.input_enabled = false		
		if is_closed:
			await open_doors(leads_to)
		else:
			await close_doors(leads_to)
		player.queue_free()

func open_doors(leads_to_direct) -> void:
	var tween_front = get_tree().create_tween()
	tween_front.tween_property($LeftFrontDoor, "position:x", $LeftFrontDoor.position.x - len_from_center_front, 2.5) # object, property, value, time
	tween_front.parallel().tween_property($RightFrontDoor, "position:x", $RightFrontDoor.position.x + len_from_center_front, 2.5)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_back = get_tree().create_tween()
	tween_back.tween_property($RightBackDoor, "position:x", $RightBackDoor.position.x + len_from_center_back, 2.5)
	tween_back.parallel().tween_property($LeftBackDoor, "position:x", $LeftBackDoor.position.x - len_from_center_back, 2.5)
	
	await tween_back.finished
	await get_tree().create_timer(.5).timeout
	
	player.hide()
	$BG.play("sit")
	await get_tree().create_timer(.2).timeout
	
	#var tween_elevator = get_tree().create_tween()
	#tween_elevator.tween_property($BG, "position:y", $BG.position.y - 500, 7.0)
	#tween_elevator.parallel().tween_property($RightBackDoor, "position:y", $RightBackDoor.position.y - 500, 7.0)
	#tween_elevator.parallel().tween_property($LeftBackDoor, "position:y", $LeftBackDoor.position.y - 500, 7.0)
	
	await get_tree().create_timer(2.0).timeout
	$BG.play("sitting_only")
	
	var tween_front_close = get_tree().create_tween()
	tween_front_close.tween_property($LeftFrontDoor, "position:x", $LeftFrontDoor.position.x + len_from_center_front, 2.5) # object, property, value, time
	tween_front_close.parallel().tween_property($RightFrontDoor, "position:x", $RightFrontDoor.position.x - len_from_center_front, 2.5)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_back_close = get_tree().create_tween()
	tween_back_close.tween_property($RightBackDoor, "position:x", $RightBackDoor.position.x - len_from_center_back, 2.5)
	tween_back_close.parallel().tween_property($LeftBackDoor, "position:x", $LeftBackDoor.position.x + len_from_center_back, 2.5)
	
	await tween_back_close.finished
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
	tween_front.tween_property($LeftFrontDoor, "position:x", $LeftFrontDoor.position.x + len_from_center_front, 2.5) # object, property, value, time
	tween_front.parallel().tween_property($RightFrontDoor, "position:x", $RightFrontDoor.position.x - len_from_center_front, 2.5)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_back = get_tree().create_tween()
	tween_back.tween_property($RightBackDoor, "position:x", $RightBackDoor.position.x - len_from_center_back, 2.5)
	tween_back.parallel().tween_property($LeftBackDoor, "position:x", $LeftBackDoor.position.x + len_from_center_back, 2.5)
	
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
	
func transition_to(to: PackedScene) -> void:
	get_tree().change_scene_to_packed(to)

############################
#          SIGNALS         #
############################
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = body
