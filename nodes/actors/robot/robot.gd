extends CharacterBody2D


const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

func get_input():
	if Input.is_action_pressed("left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("right"):
		velocity.x =  SPEED
	else:
		velocity.x = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	get_input()
	move_and_slide()
