extends Control

var task1: String
var task2: String
var task3: String

func _ready() -> void:
	$Texture/Task1.text = task1
	$Texture/Task2.text = task2
	$Texture/Task3.text = task3

func set_task1(str: String) -> void:
	$Texture/Task1.text = str
	
func set_task2(str: String) -> void:
	$Texture/Task2.text = str
	
func set_task3(str: String) -> void:
	$Texture/Task3.text = str
