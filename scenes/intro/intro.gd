extends Node2D

@export var robot_scene: PackedScene # the controllable Robot
@export var ambience: AudioStream

@onready var dummy_robot: Node2D = $DummyRobot  # the robot that plays the wake-up animation
@onready var anim_player: AnimatedSprite2D = $DummyRobot/Animation2D
@onready var shade_player: AnimationPlayer = $InitialShade/AnimationPlayer
@onready var scene_camera: Camera2D = $Camera2D

var robot_spawned: bool = false

func _ready() -> void:
	GameState.last_level = GameState.LEVELS.LEVEL_1
	if !GameManager.initialSequenceCompleted:
		$InitialShade.show()
	else:
		AudioManager.play_ambience(ambience)
		var robot_instance = robot_scene.instantiate() as Robot
		
		robot_instance.is_intro_sequence = false
		robot_instance.z_index = 50
		
		if GameManager.player_return_position != null:
			robot_instance.global_position = GameManager.player_return_position
		else:
			robot_instance.global_position = dummy_robot.global_position
		add_child(robot_instance)
		robot_instance.last_state = Robot.State.IDLE
		
		$InitialShade.queue_free()
		dummy_robot.queue_free()
		scene_camera.queue_free()

func _process(delta: float) -> void:
	if robot_spawned:
		return
		
	if (Input.is_action_pressed("interact") or Input.is_action_pressed("left") or Input.is_action_pressed("right")) and !GameManager.initialSequenceCompleted:
		set_process(false)
		AudioManager.play_ambience(ambience)
		await play_dummy_animation()
		await spawn_controllable_robot()
		robot_spawned = true
		GameManager.initialSequenceCompleted = true
			
		$LandLordS.play()
		await $LandLordS.finished
		await get_tree().create_timer(3.0).timeout
		$Propaganda.play()
		
	# --check for input until possible key is pressed
	# --wake up robot (sitting in corner) -> animation
	# --level starts on wake up
	# on first level symbols on doors (E)

func play_dummy_animation() -> void:
	$DummyRobot/Zwoom.play()
	anim_player.play("default")
	shade_player.play("default")
	await anim_player.animation_finished

func spawn_controllable_robot() -> void:
	# TODO fix the camera "jump" at the end
	var robot_instance = robot_scene.instantiate() as Robot
	robot_instance.is_intro_sequence = true
	robot_instance.z_index = 50
	robot_instance.global_position = anim_player.global_position 
	add_child(robot_instance)
	robot_instance.last_state = Robot.State.IDLE
	robot_instance.task1 = "Aktualizuj servery"
	robot_instance.set_task1("Aktualizuj servery")
	
	dummy_robot.queue_free()
	
	var robot_camera: Camera2D = robot_instance.get_node("Camera2D")
	var target_zoom: Vector2 = robot_camera.zoom
	var target_position: Vector2 = robot_camera.global_position
	var target_offset = robot_camera.offset

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(scene_camera, "global_position", target_position, 2.5)
	tween.tween_property(scene_camera, "zoom", target_zoom, 2.5)
	tween.tween_property(scene_camera, "offset", target_offset, 2.5)
	
	robot_instance.input_enabled = false
	await tween.finished
	
	#scene_camera.global_position = robot_camera.global_position
	#scene_camera.offset = robot_camera.offset
	
	scene_camera.queue_free()
	robot_camera.enabled = true
	robot_camera.make_current()
	robot_instance.input_enabled = true
	
###############################################################
# On left doors
#  -
# Voice line - come to the left door
# 	Zadá quest - jít deletnout historii
# Landlord zadá jdi aktualizovat systém - tablet na stěně
