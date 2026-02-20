extends CharacterBody2D
class_name Robot

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

var current_state: State = State.IDLE
var energy: int = 10 # TODO balance this

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

func walk_in() -> void:
	var animation = get_tree().create_tween()
	animation.tween_property(self, "scale", self.scale * 0.7, 2.5) # object, property, value, time
	animation.parallel().tween_property(self, "position:y", self.position.y - 15, 2.5)
	
	await animation.finished
		
func update_animation(state: State):	
	if state == State.WALK_LEFT:
		sprite.play("walk_forward")
	elif state == State.WALK_RIGHT:
		sprite.play("walk_forward")
	else:
		sprite.play("idle")
