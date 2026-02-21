extends Node2D

# --- Nastavení času ---
@export var time_limit: float = 15.0 
var current_time: float

# --- Uzly ---
@onready var message_begin = $MessageBegin
@onready var message_complete = $MessageComplete
@onready var breaker_panel = $BreakerPanel
@onready var timer_bar = $TimerUI/ProgressBar

# --- Data hry ---
var game_started: bool = false
var game_finished: bool = false
var broken_indices: Array = []
var active_states: Array = [false, false, false, false, false, false, false, false, false, false]
var small_breaker_areas: Array = []

# --- Assets (Cesty opraveny podle tvého zadání) ---
var tex_main_on = preload("res://assets/tasks/Breakers/breaker_main_on.png")
var tex_main_off = preload("res://assets/tasks/Breakers/breaker_main_off.png")
var tex_small_on = preload("res://assets/tasks/Breakers/breaker_normal_on.png")
var tex_small_off = preload("res://assets/tasks/Breakers/breaker_normal_off.png")

func _ready():
	current_time = time_limit
	timer_bar.max_value = time_limit
	timer_bar.value = time_limit
	
	# Výchozí stavy
	message_begin.visible = true
	message_complete.visible = false
	breaker_panel.visible = false
	timer_bar.visible = false
	
	# Registrace všech 10 jističů
	for i in range(1, 11):
		var area = breaker_panel.get_node("Small" + str(i))
		small_breaker_areas.append(area)
		area.input_event.connect(_on_small_breaker_clicked.bind(i-1))

	# Registrace hlavního jističe a Start tlačítka
	$BreakerPanel/MainBreaker.input_event.connect(_on_main_breaker_clicked)
	message_begin.get_node("Success").input_event.connect(_on_begin_clicked)

func _process(delta):
	if game_started and not game_finished:
		current_time -= delta
		timer_bar.value = current_time
		
		# Vizuální varování (barevný glitch při nedostatku času)
		if current_time < 4.0:
			timer_bar.modulate = Color.RED if Engine.get_frames_drawn() % 10 < 5 else Color.WHITE
		
		if current_time <= 0:
			_on_timer_out()

# --- Zahájení ---
func _on_begin_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and not game_started:
		_start_game()

func _start_game():
	game_started = true
	message_begin.visible = false
	breaker_panel.visible = true
	timer_bar.visible = true
	
	# Náhodně vybereme 2 až 4 sabotované jističe
	var indices = range(10)
	indices.shuffle()
	broken_indices = indices.slice(0, randi_range(2, 4))

# --- Interakce ---
func _on_small_breaker_clicked(_v, event, _s, idx):
	if event is InputEventMouseButton and event.pressed and not game_finished:
		active_states[idx] = !active_states[idx]
		_update_visuals(idx)

func _update_visuals(idx):
	var spr = small_breaker_areas[idx].get_node("Sprite2D")
	spr.texture = tex_small_on if active_states[idx] else tex_small_off

func _on_main_breaker_clicked(_v, event, _s):
	if event is InputEventMouseButton and event.pressed and not game_finished:
		_check_circuits()

func _check_circuits():
	var caused_short = false
	for idx in broken_indices:
		if active_states[idx]: 
			caused_short = true
			break
	
	if caused_short:
		# Zkrat: Vše vypnout a penalizace času -3 vteřiny
		current_time -= 3.0
		for i in range(10):
			active_states[i] = false
			_update_visuals(i)
		# Efekt zkratu (červené probliknutí panelu)
		_flash_screen()
	else:
		# Kontrola výhry: Všechny funkční jističe musí být zapnuté
		var is_win = true
		for i in range(10):
			if not i in broken_indices and not active_states[i]:
				is_win = false
		
		if is_win:
			_finish_game()

# --- Konce hry ---
func _on_timer_out():
	game_finished = true
	# Reset scény při selhání (jako v Dumb Ways to Die)
	get_tree().reload_current_scene() 

func _finish_game():
	game_finished = true
	breaker_panel.visible = false
	timer_bar.visible = false
	# Zobrazení finální textury na hlavním jističi
	$BreakerPanel/MainBreaker/Sprite2D.texture = tex_main_on
	message_complete.visible = true
	message_complete.position = get_viewport_rect().size / 2

func _flash_screen():
	var t = create_tween()
	breaker_panel.modulate = Color(2, 0.5, 0.5) # Over-bright červená
	t.tween_property(breaker_panel, "modulate", Color.WHITE, 0.2)
