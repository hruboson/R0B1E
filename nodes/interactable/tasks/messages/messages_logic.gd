extends Node2D

@export var associated_task: String
@export var level_key: String = GameState.level_key
@export var quest_key: String = GameState.quest_key

const TOTAL_SLOTS := 10
const MAX_MESSAGES := 16

var message_textures: Array[Texture2D] = []

var required_slots: Array[int] = []
var clicked_slots: Array[int] = []

func _ready():
	randomize()  # ensure randomness each run

	var min_populated := 7
	var num_populated := randi() % (TOTAL_SLOTS - min_populated + 1) + min_populated
	var num_required := randi() % num_populated + 1

	required_slots = []
	for i in range(1, num_required + 1):
		required_slots.append(i)

	for i in range(1, num_populated + 1):
		var slot = get_node("Slot%d" % i)
		var sprite = Sprite2D.new()

		# Random message from 1..16
		var msg_index := randi() % MAX_MESSAGES + 1
		sprite.texture = load("res://assets/tasks/messages/message_%d.png" % msg_index)

		sprite.name = "MessageSprite"
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		# Highlight required slots
		if i in required_slots:
			sprite.modulate = Color(1.3, 1.3, 1.3, 1.0)

		slot.add_child(sprite)
		slot.input_event.connect(_on_slot_clicked.bind(i))

		# Position sprite on top-left of collision shape
		var collision: CollisionShape2D = slot.get_node("CollisionShape2D")
		var rect_shape: RectangleShape2D = collision.shape
		var rect_size = rect_shape.size * collision.scale
		var top_left = collision.position - rect_size / 2.0 + Vector2(0, 2)
		sprite.position = top_left.round()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _on_slot_clicked(viewport, event, shape_idx, slot_number):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		# If slot is one of required ones
		if slot_number in required_slots \
		and slot_number not in clicked_slots:

			clicked_slots.append(slot_number)
			get_node("Slot%d/MessageSprite" % slot_number).hide()

			# Check if all required were clicked
			if clicked_slots.size() == required_slots.size():
				GameState.complete_quest()
				await get_tree().create_timer(0.5).timeout

				if GameManager.previous_scene_path != "":
					get_tree().change_scene_to_file(GameManager.previous_scene_path)

		else:
			# slot not required
			pass
