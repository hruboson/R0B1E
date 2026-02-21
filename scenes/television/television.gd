extends Area2D

@export_file("*.tscn") var next_scene: String = ""
var failed: bool = false

func _ready() -> void:
	$Control/Failed.hide()
	$Control/Passed.hide()
	display_task_counts()

func display_task_counts() -> void:
	var level_data = {}
	
	# Select the correct level dictionary
	match GameState.last_level:
		GameState.LEVELS.LEVEL_1:
			level_data = GameState.level1
		GameState.LEVELS.LEVEL_2:
			level_data = GameState.level2
		GameState.LEVELS.LEVEL_3:
			level_data = GameState.level3
	
	var landlord_done = 0
	var landlord_total = 0
	var tenant_done = 0
	var tenant_total = 0
	
	# Count completed and total tasks per category
	for key in level_data.keys():
		if key.begins_with("questLandlord"):
			landlord_total += 1
			if level_data[key]:
				landlord_done += 1
		else:
			tenant_total += 1
			if level_data[key]:
				tenant_done += 1
	
	$Control/TaskLandlord/Score.text = str(landlord_done) + "/" + str(landlord_total)
	$Control/TaskTenants/Score.text = str(tenant_done) + "/" + str(tenant_total)
	
	if landlord_done != landlord_total:
		$Control/Failed.show()
		failed = true
		return
					
	$Control/Passed.show()


func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		move_on()

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		move_on()

func move_on():
	if failed:
		game_over()
		return
	if next_scene == "":
		return
	get_tree().change_scene_to_file(next_scene)
	
func game_over():
	GameManager.initialSequenceCompleted = false
	get_tree().change_scene_to_file("res://scenes/intro/intro.tscn")
