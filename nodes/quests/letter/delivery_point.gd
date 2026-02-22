extends Area2D

########## EXPORTS ###########
@export var point_type: String = "A"  # "A" or "B"

# Audio and subtitles for Point A
@export_group("Point A - First Letter Pickup")
@export_multiline var a_pickup_subtitles: String = ""
@export_multiline var a_pickup_subtitles_optional: String = ""
@export var a_pickup_sub_length: float = 3.0
@export var a_pickup_sub_optional_length: float = 3.0
@export var a_pickup_audio: AudioStream

@export_group("Point A - Return Letter Delivery")
@export_multiline var a_delivery_subtitles: String = ""
@export_multiline var a_delivery_subtitles_optional: String = ""
@export var a_delivery_sub_length: float = 3.0
@export var a_delivery_sub_optional_length: float = 3.0
@export var a_delivery_audio: AudioStream

# Audio and subtitles for Point B
@export_group("Point B - First Letter Delivery")
@export_multiline var b_delivery_subtitles: String = ""
@export var b_delivery_sub_length: float = 3.0
@export var b_delivery_audio: AudioStream

@export_group("Point B - Return Letter Auto-pickup")
@export_multiline var b_auto_pickup_subtitles: String = ""
@export var b_auto_pickup_sub_length: float = 3.0
@export var b_auto_pickup_audio: AudioStream

########## NODES ############
@onready var audio_player: AudioStreamPlayer = $"../AudioStreamPlayer"

var player: Robot = null
var player_in_area = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	LetterQuest.quest_state_changed.connect(_on_quest_state_changed)
	
	# Initial update of letter visibility
	update_letter_visibility()

func _process(_delta):
	if Input.is_action_just_pressed("interact") and player and player.input_enabled:
		handle_interaction()

func handle_interaction():
	var current_state = LetterQuest.current_state
	
	if point_type == "A":
		if current_state == LetterQuest.QuestState.WAITING_FOR_FIRST_LETTER:
			if LetterQuest.pickup_letter("A"):
				play_audio_and_subtitles("pickup")
				update_letter_visibility()  # Show letter after pickup
				
		elif current_state == LetterQuest.QuestState.HAS_SECOND_LETTER:
			if LetterQuest.deliver_letter("A"):
				play_audio_and_subtitles("delivery")
				update_letter_visibility()  # Hide letter after delivery
	
	elif point_type == "B":
		if current_state == LetterQuest.QuestState.HAS_FIRST_LETTER:
			if LetterQuest.deliver_letter("B"):
				play_audio_and_subtitles("delivery")
				update_letter_visibility()  # Letter still visible? Will be hidden after auto-pickup?
				await get_tree().create_timer(0.5).timeout
				auto_pickup_return_letter()

func auto_pickup_return_letter():
	play_audio_and_subtitles("auto_pickup")
	LetterQuest.pickup_letter("B")
	update_letter_visibility()  # Show return letter

func play_audio_and_subtitles(action: String):
	match point_type:
		"A":
			match action:
				"pickup":
					if a_pickup_audio:
						audio_player.stream = a_pickup_audio
						audio_player.play()
					player.init_tenant_quest(
						a_pickup_subtitles, 
						a_pickup_subtitles_optional, 
						a_pickup_sub_length, 
						a_pickup_sub_optional_length
					)
				"delivery":
					if a_delivery_audio:
						audio_player.stream = a_delivery_audio
						audio_player.play()
					player.init_tenant_quest(
						a_delivery_subtitles, 
						a_delivery_subtitles_optional, 
						a_delivery_sub_length, 
						a_delivery_sub_optional_length
					)
		"B":
			match action:
				"delivery":
					if b_delivery_audio:
						audio_player.stream = b_delivery_audio
						audio_player.play()
					player.show_text(b_delivery_subtitles, b_delivery_sub_length)
				"auto_pickup":
					if b_auto_pickup_audio:
						audio_player.stream = b_auto_pickup_audio
						audio_player.play()
					player.show_text(b_auto_pickup_subtitles, b_auto_pickup_sub_length)

func update_letter_visibility():
	# Always find the robot fresh from the scene tree
	var robot = get_tree().get_first_node_in_group("player")
	if robot:
		update_robot_letter(robot)

func update_robot_letter(robot_node: Robot):
	var current_state = LetterQuest.current_state
	var should_show = (current_state == LetterQuest.QuestState.HAS_FIRST_LETTER or 
					  current_state == LetterQuest.QuestState.HAS_SECOND_LETTER)
	
	# Directly access the TextureRect in CanvasLayer
	var letter_texture_rect = robot_node.get_node_or_null("CanvasLayer/Letter")
	if letter_texture_rect:
		letter_texture_rect.visible = should_show
	else:
		print("Warning: Could not find CanvasLayer/TextureRect in robot node")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_area = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
		player_in_area = false

func _on_quest_state_changed(_state):
	update_letter_visibility()
