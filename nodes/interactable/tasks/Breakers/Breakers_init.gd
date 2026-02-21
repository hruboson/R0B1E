extends Area2D

var player: Node2D = null

func _process(_delta: float) -> void:
	# Kontrola, zda hráč zmáčkl E
	if player != null and Input.is_action_just_pressed("interact"):
		open_minigame()

func open_minigame() -> void:
	# Cesta k minihře
	var path = "res://scenes/tasks/Breakers/Breaker.tscn"
	
	if not FileAccess.file_exists(path):
		print("CHYBA: Soubor nenalezen: ", path)
		return

	var task_scene = load(path)
	if task_scene:
		var task_instance = task_scene.instantiate()
		get_tree().current_scene.add_child(task_instance)
		
		# Zastavení robota
		if player.has_method("set_physics_process"):
			player.set_physics_process(false)

# SIGNÁLY (Propoj v editoru v záložce Node)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
