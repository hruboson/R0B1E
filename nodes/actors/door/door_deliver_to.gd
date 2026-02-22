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
var quest_active: int = 0
var enabled = true

func _ready() -> void:
	if audio_stream:
		audio_player.stream = audio_stream  # assign exported stream

func _process(delta: float) -> void:
	if !enabled:
		return 
		
	# jesus christ I'm tired...
	if GameState.letter1Active:
		if !GameState.levels_state["level2"]["quest2A"]:
			quest_active = 1
		else:
			quest_active = 0
	elif GameState.letter2Active:
		if !GameState.levels_state["level2"]["quest2B"]:
			quest_active = 2
		else:
			quest_active = 0
		
	if player != null and Input.is_action_just_pressed("interact"):
		if player.input_enabled and quest_active == waiting_for_quest:
			# holy mother smoking barrel of gun
			if quest_active == 1:
				GameState.letter1Active = false
				GameState.levels_state["level2"]["quest2A"] = true
			if quest_active == 2:
				GameState.letter2Active = false
				GameState.levels_state["level2"]["quest2B"] = true
				
			player.show_text(subtitles, subtitle_len)
			audio_player.play()
			await audio_player.finished
			
			# motherfucking jesus, get me out of here
			# what a fucking hacks, please kill me now
			if quest_active == 1:
				quest_active = 2
				GameState.letter2Active = true
				enable.enabled = true
				enable.position.x += 200
				self.position.x += 1000
			elif quest_active == 2:
				deactivate.enabled = false
				deactivate.position.x -= 1000
				self.position.x -= 1000
				player.show_text("")
				quest_active = 0


func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body.is_in_group("player"):
		player = null
