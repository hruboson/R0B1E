extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite

##########################
# 		CONSTANTS        #
##########################

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
enum State { IDLE, WALK_LEFT, WALK_RIGHT, INTERACT }

###########################
# 		PROPERTIES		  #
###########################

var current_state = State.IDLE

func _physics_process(delta: float) -> void:
	if not is_on_floor(): # gravity
		velocity += get_gravity() * delta

	var state = get_input()
	move_and_slide()
	update_animation(state)

func get_input() -> State:
	if Input.is_action_pressed("left"):
		velocity.x = -SPEED
		return State.WALK_LEFT
	elif Input.is_action_pressed("right"):
		velocity.x =  SPEED
		return State.WALK_LEFT
	else:
		velocity.x = 0
		return State.IDLE
		
func update_animation(state: State):	
	if state == State.WALK_LEFT:
		sprite.play("walk_forward")
	elif state == State.WALK_RIGHT:
		sprite.play("walk_forward")
	else:
		sprite.play("idle")
