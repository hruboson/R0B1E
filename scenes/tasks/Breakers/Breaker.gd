extends Node2D

@export var spawn_margin: float = 200.0
@export var required_successes: int = 8   # how many successful clicks to win

@onready var message_begin: Sprite2D = $MessageBegin
@onready var message_complete: Sprite2D = $MessageComplete

@onready var popup_templates := [
	$Message1,
	$Message2,
	$Message3
]

var rng := RandomNumberGenerator.new()
var success_count: int = 0
var game_started: bool = false
var game_finished: bool = false


# --------------------------------------------------
# READY
# --------------------------------------------------
func _ready():
	rng.randomize()

	# Hide everything except Begin
	for popup in popup_templates:
		popup.visible = false
	message_complete.visible = false
	message_begin.visible = true

	_connect_begin_popup()


# --------------------------------------------------
# BEGIN CLICK
# --------------------------------------------------
func _connect_begin_popup():
	var success_area = message_begin.get_node("Success")
	success_area.input_event.connect(_on_begin_clicked)


func _on_begin_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if game_started:
			return

		game_started = true
		message_begin.visible = false
		
		_spawn_random_popup()


# --------------------------------------------------
# SPAWNING GAME POPUPS
# --------------------------------------------------
func _spawn_random_popup():
	if game_finished:
		return

	var template = popup_templates[rng.randi_range(0, popup_templates.size() - 1)]
	var popup = template.duplicate()

	add_child(popup)
	popup.visible = true
	popup.position = _get_random_position()

	_connect_popup(popup)


func _connect_popup(popup: Sprite2D):
	var success_area = popup.get_node("Success")
	var failure_area = popup.get_node("Failure")

	success_area.input_event.connect(_on_success_clicked.bind(popup))

	if failure_area:
		failure_area.input_event.connect(_on_failure_clicked.bind(popup))


# --------------------------------------------------
# SUCCESS
# --------------------------------------------------
func _on_success_clicked(viewport, event, shape_idx, popup):
	if event is InputEventMouseButton and event.pressed and not game_finished:

		popup.queue_free()
		success_count += 1

		if success_count >= required_successes:
			_finish_game()
		else:
			_spawn_random_popup()


# --------------------------------------------------
# FAILURE
# --------------------------------------------------
func _on_failure_clicked(viewport, event, shape_idx, popup):
	if event is InputEventMouseButton and event.pressed and not game_finished:

		# duplicate more popups to increase difficulty
		for i in 2:
			_spawn_random_popup()


# --------------------------------------------------
# FINISH GAME
# --------------------------------------------------
func _finish_game():
	game_finished = true

	# remove all active popups
	for child in get_children():
		if child in popup_templates:
			continue
		if child != message_complete and child != message_begin:
			if child is Sprite2D:
				child.queue_free()

	message_complete.visible = true
	message_complete.position = get_viewport_rect().size / 2


# --------------------------------------------------
# RANDOM POSITION
# --------------------------------------------------
func _get_random_position() -> Vector2:
	var screen_size = get_viewport_rect().size
	
	return Vector2(
		rng.randf_range(spawn_margin, screen_size.x - spawn_margin),
		rng.randf_range(spawn_margin, screen_size.y - spawn_margin)
	)
