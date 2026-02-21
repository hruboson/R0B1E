extends Node2D

@export var spawn_margin: float = 200.0
@export var required_successes: int = 8   # how many successful clicks to win
@export var start_popup_count: int = 3   # minimum popups on start

@onready var message_begin: Sprite2D = $MessageBegin
@onready var message_complete: Sprite2D = $MessageComplete
@onready var bg: Sprite2D = $BG

@onready var popup_templates := [
	$Message1,
	$Message2,
	$Message3
]

var rng := RandomNumberGenerator.new()
var success_count: int = 0
var game_started: bool = false
var game_finished: bool = false

func _ready():
	rng.randomize()
	
	# hide everything except Begin
	for popup in popup_templates:
		popup.visible = false
	message_complete.visible = false
	message_begin.visible = true

	_connect_begin_popup()

func _connect_begin_popup():
	var success_area = message_begin.get_node("Success")
	success_area.input_event.connect(_on_begin_clicked)


func _on_begin_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if game_started:
			return

		game_started = true
		message_begin.visible = false
		
		for i in start_popup_count:
			_spawn_random_popup()

func _spawn_random_popup():
	if game_finished:
		return

	var template = popup_templates[rng.randi_range(0, popup_templates.size() - 1)]
	var popup = template.duplicate()

	add_child(popup)
	popup.visible = true
	popup.position = _get_random_position(popup)

	_connect_popup(popup)


func _connect_popup(popup: Sprite2D):
	var success_area = popup.get_node("Success")
	var failure_area = popup.get_node("Failure")

	success_area.input_event.connect(_on_success_clicked.bind(popup))

	if failure_area:
		failure_area.input_event.connect(_on_failure_clicked.bind(popup))

func _on_success_clicked(viewport, event, shape_idx, popup):
	if event is InputEventMouseButton and event.pressed and not game_finished:

		popup.queue_free()
		success_count += 1

		if success_count >= required_successes:
			_show_final_message()
		else:
			_spawn_random_popup()


func _on_failure_clicked(viewport, event, shape_idx, popup):
	if event is InputEventMouseButton and event.pressed and not game_finished:

		# duplicate more popups to increase difficulty
		for i in randi() % 3 + 1:
			_spawn_random_popup()

func _show_final_message():
	message_complete.visible = true
	message_complete.global_position = bg.global_position
	message_complete.z_index = 0   # popups are higher so final message is behind

	var success_area = message_complete.get_node("Success")
	if not success_area.input_event.is_connected(_on_final_success_clicked):
		success_area.input_event.connect(_on_final_success_clicked)

	var failure_area = message_complete.get_node_or_null("Failure")
	if failure_area and not failure_area.input_event.is_connected(_on_final_failure_clicked):
		failure_area.input_event.connect(_on_final_failure_clicked)

func _finish_game():
	game_finished = true

	message_complete.visible = true
	message_complete.global_position = bg.global_position
	message_complete.z_index = -10

	var success_area = message_complete.get_node("Success")
	success_area.input_event.connect(_on_final_success_clicked)
	
func _on_final_success_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:

		await get_tree().create_timer(0.5).timeout

		if GameManager.previous_scene_path != "":
			get_tree().change_scene_to_file(GameManager.previous_scene_path)

func _on_final_failure_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		message_complete.global_position = _get_random_position(message_complete)

func _get_random_position(popup: Sprite2D) -> Vector2:
	var bg_size = bg.texture.get_size() * bg.scale
	var bg_top_left = bg.global_position - bg_size / 2
	var bg_bottom_right = bg.global_position + bg_size / 2

	var popup_size = popup.texture.get_size() * popup.scale
	var half_popup = popup_size / 2

	var min_x = bg_top_left.x + half_popup.x + spawn_margin
	var max_x = bg_bottom_right.x - half_popup.x - spawn_margin
	var min_y = bg_top_left.y + half_popup.y + spawn_margin
	var max_y = bg_bottom_right.y - half_popup.y - spawn_margin

	return Vector2(
		rng.randf_range(min_x, max_x),
		rng.randf_range(min_y, max_y)
	)
