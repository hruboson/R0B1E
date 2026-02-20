extends Node2D

########## EXPORTS ###########
@export var leads_to: PackedScene

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
	var animation = get_tree().create_tween()
	
	# object, property, value, time
	animation.tween_property($LeftDoor, "position:x", $LeftDoor.position.x + 50, 0) # 2.5
	animation.parallel().tween_property($RightDoor, "position:x", $RightDoor.position.x - 50, 0) # 2.5
	
	if(leads_to_direct):
		animation.tween_callback(transition_to.bind(leads_to_direct))
	else:
		animation.tween_callback(transition_to.bind(leads_to))
	
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
