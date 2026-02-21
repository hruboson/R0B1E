extends Node2D

const TOTAL_SLOTS := 10

var message_textures: Array[Texture2D] = []

var required_slots: Array[int] = []
var clicked_slots: Array[int] = []

func _ready():
	for i in range(1, 11):
		var path = "res://assets/tasks/messages/message_%d.png" % i
		var tex = load(path)
		if tex:
			message_textures.append(tex)
	
	message_textures.shuffle()
	var amount_required := 7

	var all_slots := []
	for i in range(1, TOTAL_SLOTS + 1):
		all_slots.append(i)

	all_slots.shuffle()

	required_slots = []
	for i in range(amount_required):
		required_slots.append(all_slots[i])

	print("Player must click:", required_slots)
	
	for i in range(1, 11):
		var slot = get_node("Slot%d" % i)
		var sprite = Sprite2D.new()
		sprite.texture = message_textures[i - 1]
		sprite.name = "MessageSprite"
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		# Slight highlight for required slots
		if i in required_slots:
			sprite.modulate = Color(1.3, 1.3, 1.3, 1.0)

		slot.add_child(sprite)

		slot.input_event.connect(_on_slot_clicked.bind(i))

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

			print("Correct slot:", slot_number)

			clicked_slots.append(slot_number)
			get_node("Slot%d/MessageSprite" % slot_number).hide()

			# Check if all required were clicked
			if clicked_slots.size() == required_slots.size():
				print("All required slots clicked!")
				#emit_signal("all_messages_clicked")

		else:
			print("This slot is not required.")
