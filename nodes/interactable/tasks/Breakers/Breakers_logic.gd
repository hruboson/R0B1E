extends CanvasLayer

@export var time_limit: float = 15.0
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
		
		# Blikání při docházejícím čase
		if current_time < 5.0 and timer_bar:
			timer_bar.modulate = Color.RED if Engine.get_frames_drawn() % 10 < 5 else Color.WHITE
		
		if current_time <= 0:
			_close_game()

func _start_logic() -> void:
	game_started = true
	# Náhodný výběr sabotovaných jističů
	var all = range(small_breaker_areas.size())
	all.shuffle()
	broken_indices = all.slice(0, randi_range(2, 4))
	print("Hra běží. Sabotáž na indexech: ", broken_indices)

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
	if event is InputEventMouseButton and event.pressed and not game_finished:
		_evaluate_game()

func _evaluate_game() -> void:
	# Prohra při zapnutí sabotovaného
	for idx in broken_indices:
		if active_states[idx]:
			_fail_effect()
			return
	
	# Kontrola, zda jsou všechny zdravé zapnuté
	var win = true
	for i in range(small_breaker_areas.size()):
		if not i in broken_indices and not active_states[i]:
			win = false
	
	if win: _win_effect()

func _fail_effect() -> void:
	current_time -= 3.0
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
	var p = get_tree().get_first_node_in_group("player")
	if p: p.set_physics_process(true)
	queue_free()
