extends Node

@onready var ambience_best: AudioStreamPlayer = $AmbienceBest

var current_music: AudioStream = null

func play_ambience(stream: AudioStream):
	if current_music == stream:
		return

	current_music = stream
	ambience_best.stop()
	ambience_best.stream = stream
	ambience_best.play()

func stop_ambience():
	ambience_best.stop()
	current_music = null
