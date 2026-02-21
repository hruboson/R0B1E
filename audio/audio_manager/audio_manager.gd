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

func play_1A():
	print("Playing 1A")
	pass
	
func play_2A():
	print("Playing 2A")
	pass
	
func play_1B():
	print("Playing 1B")
	pass
	
func play_2B():
	print("Playing 2B")
	pass
	
func res_A3_scratching():
	pass
	
func res_B3_chopping():
	pass
	
func propaganda_1():
	pass
	
func propaganda_2():
	pass

func landlord_1S():
	pass

func landlord_1F():
	pass
	
func landlord_2S():
	pass
	
func landlord_2F():
	pass

func landlord_3S():
	pass

func landlord_3F():
	pass
	
func landlord_4F():
	pass

func stop_ambience():
	ambience_best.stop()
	current_music = null
