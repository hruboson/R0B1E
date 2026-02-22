extends Node2D

@export var time_limit: float = 10.0 # seconds
@export var fade_speed: float = 0.15 # how fast FG becomes opaque
@export var level_key: String = GameState.level_key
@export var quest_key: String = GameState.quest_key

var timer: float
var fg_sprite: Sprite2D
var sliders: Array[HSlider]

func _ready():
	timer = time_limit
	fg_sprite = $FG
	fg_sprite.modulate.a = 0.0

	# Collect all HSliders in the Control node
	sliders = [
		$Control/HSlider,
		$Control/HSlider2,
		$Control/HSlider3,
		$Control/HSlider4,
		$Control/HSlider5
	]

func _process(delta):
	# Update timer
	timer -= delta
	if timer < 0:
		timer = 0

	# Fade in FG
	fg_sprite.modulate.a = min(fg_sprite.modulate.a + fade_speed * delta, 1.0)

	# Check if FG fully opaque
	if fg_sprite.modulate.a >= 1.0:
		# failure
		await get_tree().create_timer(0.5).timeout
		if GameManager.previous_scene_path != "":
			get_tree().change_scene_to_file(GameManager.previous_scene_path)

	# Check if all sliders are maxed (example: value == max_value)
	var all_done = true
	for s in sliders:
		if s.value < s.max_value:
			all_done = false
			break

	if all_done:
		GameState.complete_quest()
		await get_tree().create_timer(0.5).timeout
		if GameManager.previous_scene_path != "":
			get_tree().change_scene_to_file(GameManager.previous_scene_path)
