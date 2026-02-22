extends Area2D

@export var waiting_for_quest: int = 0
@export var audio_stream: AudioStream
@export var is_enabled: bool = false
@export var enable: Area2D # another DoorDeliverTo
@export var deactivate: Area2D # another DoorDeliverTo
@export_multiline var subtitles: String = ""
@export var subtitle_len: float = 3.0

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D  # must point to node

var player: Robot = null
var quest_completed: bool = false  # Add this flag to prevent re-triggering
var enabled = true

func _ready() -> void:
	if audio_stream:
		audio_player.stream = audio_stream  # assign exported stream

func _process(delta: float) -> void:
	if !enabled or quest_completed:  # Don't process if quest is already completed
		return 
		
	# Check if the quest should be active based on GameState
	if waiting_for_quest == 1:
		if GameState.letter1Active and !GameState.levels_state["level2"]["quest2A"]:
			# Quest is active
			pass
		else:
			return  # Quest not active
	elif waiting_for_quest == 2:
		if GameState.letter2Active and !GameState.levels_state["level2"]["quest2B"]:
			# Quest is active
			pass
		else:
			return  # Quest not active
			
	if player != null and Input.is_action_just_pressed("interact"):
		if player.input_enabled:
			# Complete the quest
			if waiting_for_quest == 1:
				GameState.letter1Active = false
				GameState.levels_state["level2"]["quest2A"] = true
				quest_completed = true  # Mark as completed
				
				# Trigger next quest
				GameState.letter2Active = true
				enable.enabled = true
				enable.position.x += 200
				self.position.x += 1000
				
			elif waiting_for_quest == 2:
				GameState.letter2Active = false
				GameState.levels_state["level2"]["quest2B"] = true
				quest_completed = true  # Mark as completed
				
				deactivate.enabled = false
				deactivate.position.x -= 1000
				self.position.x -= 1000
			
			# Show feedback
			player.show_text(subtitles, subtitle_len)
			audio_player.play()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
