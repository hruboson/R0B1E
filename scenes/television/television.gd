extends Area2D

@export_file("*.tscn") var next_scene: String = ""

func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		move_on()

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		move_on()

func move_on():
	if next_scene == "":
		return
	get_tree().change_scene_to_file(next_scene)
