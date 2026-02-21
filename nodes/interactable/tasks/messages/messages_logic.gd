extends Node2D

# Number of messages / slots
const TOTAL_SLOTS := 10

# Store loaded textures
var message_textures: Array[Texture2D] = []

# Track click order
var next_click_index := 1

func _ready():
	for i in range(1, 10):
		var path = "res://assets/tasks/messages/message_%d.png" % i
		var tex = load(path)
		if tex:
			message_textures.append(tex)	
	
	message_textures.shuffle()
	
	for i in range(1, 10):
		var slot = get_node("Slot%d" % i)
		var sprite = Sprite2D.new()
		sprite.texture = message_textures[i - 1]
		sprite.name = "MessageSprite"
		slot.add_child(sprite)
		
		slot.connect("input_event", Callable(self, "_on_slot_clicked"), [i])

func _on_slot_clicked(viewport, event, shape_idx, slot_number):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if slot_number == next_click_index:
			print("Correct! Clicked Slot %d" % slot_number)
			next_click_index += 1
			
			# Hide clicked message
			$"Slot%d/MessageSprite" % slot_number).hide()
			
			# Check if done
			if next_click_index > TOTAL_SLOTS:
				print("All messages clicked in order! Continue...")
				emit_signal("all_messages_clicked")
		else:
			print("Wrong slot! Click slot %d next." % next_click_index)
