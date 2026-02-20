extends Control

# TODO Shade fade
# TODO Sprite
# TODO Robot animation, elevator close/open animation
# TODO Sound manager

# constructor
func _ready() -> void:
	pass # Replace with function body.

# loop
func _process(delta: float) -> void:
	pass



################################
#			BUTTONS			   #
################################

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	$Elevator.close_doors(load("res://scenes/levels/level_1/level_1.tscn"))

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu/options_menu.tscn")
