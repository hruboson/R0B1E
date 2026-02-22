extends CanvasLayer

@export var time_limit: float = 30.0
@export var level_key: String = GameState.level_key
@export var quest_key: String = GameState.quest_key

var current_time: float
var game_started: bool = false
var game_finished: bool = false

# Automatické vyhledání uzlů podle jména
@onready var message_begin = find_child("MessageBegin", true)
@onready var message_complete = find_child("MessageComplete", true)
@onready var breaker_panel = find_child("BreakerPanel", true)
@onready var timer_bar = find_child("ProgressBar", true)

const PATH = "res://assets/tasks/Breakers/"

var broken_indices: Array = []
var active_states: Array = [false, false, false, false, false, false, false, false, false, false]
var small_breaker_areas: Array = []
var game_failed: bool = false

func _ready() -> void:
	current_time = time_limit
	
	# Počáteční nastavení vizuálu
	if message_begin: message_begin.visible = false # Skryto, začínáme rovnou
	if message_complete: message_complete.visible = false
	if breaker_panel: breaker_panel.visible = true  # PANEL JE VIDĚT HNED
	if timer_bar:
		timer_bar.visible = true
		timer_bar.max_value = time_limit
		timer_bar.value = time_limit
	
	_setup_signals()
	_start_logic()

func _setup_signals() -> void:
	# Najde 10 malých jističů Small1 až Small10
	for i in range(1, 11):
		var area = find_child("Small" + str(i), true)
		if area:
			small_breaker_areas.append(area)
			if not area.input_event.is_connected(_on_small_clicked):
				area.input_event.connect(_on_small_clicked.bind(i-1))

	# Najde MainBreaker
	var main_b = find_child("MainBreaker", true)
	if main_b and not main_b.input_event.is_connected(_on_main_clicked):
		main_b.input_event.connect(_on_main_clicked)

func _process(delta: float) -> void:
	if game_started and not game_finished:
		current_time -= delta
		if timer_bar: timer_bar.value = current_time
		
		if current_time < 5.0 and timer_bar:
			timer_bar.modulate = Color.RED if Engine.get_frames_drawn() % 10 < 5 else Color.WHITE
		
		if current_time <= 0 and not game_finished:
			game_failed = true
			_fail_effect()
			game_finished = true
			await get_tree().create_timer(1.5).timeout
			_close_game()

func _start_logic() -> void:
	game_started = true
	# Náhodný výběr sabotovaných jističů
	var all = range(small_breaker_areas.size())
	all.shuffle()
	broken_indices = all.slice(0, randi_range(2, 4))
	
	var display_indices = broken_indices.map(func(x): return str(x + 1))
	$TimerUI/Label.text = "Nezapínej jističe na pozicích:\n" + ", ".join(display_indices)

func _on_small_clicked(_viewport, event, _shape_idx, idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not game_finished:
		active_states[idx] = !active_states[idx]
		_update_visual(idx)

func _update_visual(idx: int) -> void:
	var area = small_breaker_areas[idx]
	var spr = area.get_node_or_null("Sprite2D")
	if spr:
		var tex = "on" if active_states[idx] else "off"
		spr.texture = load(PATH + "breaker_normal_" + tex + ".png")
		
func _on_main_clicked(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		_evaluate_game()

func _evaluate_game() -> void:
	for idx in broken_indices:
		if active_states[idx]:
			_fail_effect()
			return

	for i in range(small_breaker_areas.size()):
		if i not in broken_indices and not active_states[i]:
			return

	_win_effect()

func _fail_effect(overall: bool = false) -> void:
	game_failed = overall or game_failed
	current_time = max(0, current_time - 3.0)
	
	if breaker_panel:
		var t = create_tween()
		breaker_panel.modulate = Color.RED
		t.tween_property(breaker_panel, "modulate", Color.WHITE, 0.2)
	
	for i in range(small_breaker_areas.size()):
		active_states[i] = false
		_update_visual(i)

func _win_effect() -> void:
	game_finished = true
	var main_b = find_child("MainBreaker", true)
	if main_b and main_b.has_node("Sprite2D"):
		main_b.get_node("Sprite2D").texture = load(PATH + "breaker_main_on.png")
	
	if message_complete: message_complete.visible = true
	await get_tree().create_timer(1.5).timeout
	_close_game()

func _close_game() -> void:
	if game_failed:
		GameManager.take_energy(2)
		get_tree().change_scene_to_file(GameManager.previous_scene_path)
	elif GameManager.previous_scene_path != "":
		GameState.complete_quest()
		get_tree().change_scene_to_file(GameManager.previous_scene_path)
	
	queue_free()
