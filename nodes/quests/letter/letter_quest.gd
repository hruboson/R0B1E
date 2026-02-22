extends Node

# Quest states
enum QuestState {
	WAITING_FOR_FIRST_LETTER,
	HAS_FIRST_LETTER,
	WAITING_FOR_SECOND_LETTER,
	HAS_SECOND_LETTER,
	COMPLETED
}

var current_state = QuestState.WAITING_FOR_FIRST_LETTER
var current_letter_type = null  # "A" or "B"

# Signals for UI updates
signal quest_state_changed(state)
signal letter_picked_up(letter_type)
signal letter_delivered(letter_type)

func start_quest():
	current_state = QuestState.WAITING_FOR_FIRST_LETTER
	current_letter_type = null
	emit_signal("quest_state_changed", current_state)

signal return_letter_auto_picked_up

func pickup_letter(letter_type):
	match current_state:
		QuestState.WAITING_FOR_FIRST_LETTER:
			if letter_type == "A":
				current_state = QuestState.HAS_FIRST_LETTER
				current_letter_type = "A"
				emit_signal("letter_picked_up", "A")
				emit_signal("quest_state_changed", current_state)
				return true
				
		QuestState.WAITING_FOR_SECOND_LETTER:
			if letter_type == "B":
				current_state = QuestState.HAS_SECOND_LETTER
				current_letter_type = "B"
				emit_signal("letter_picked_up", "B")
				emit_signal("return_letter_auto_picked_up")  # New signal
				emit_signal("quest_state_changed", current_state)
				return true
	
	return false

func deliver_letter(delivery_point_type):
	match current_state:
		QuestState.HAS_FIRST_LETTER:
			if delivery_point_type == "B":
				current_state = QuestState.WAITING_FOR_SECOND_LETTER
				current_letter_type = null
				emit_signal("letter_delivered", "A")
				emit_signal("quest_state_changed", current_state)
				return true
				
		QuestState.HAS_SECOND_LETTER:
			if delivery_point_type == "A":
				current_state = QuestState.COMPLETED
				current_letter_type = null
				emit_signal("letter_delivered", "B")
				emit_signal("quest_state_changed", current_state)
				return true
	
	return false

func get_current_letter():
	return current_letter_type

func is_completed():
	return current_state == QuestState.COMPLETED
