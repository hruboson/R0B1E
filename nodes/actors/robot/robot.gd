extends CharacterBody2D
class_name Robot

########## EXPORTS ###########
@export var walk_sound: AudioStream
@export var interact_sound: AudioStream

########## NODES ###########
@onready var sprite: AnimatedSprite2D = $AnimatedSprite
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var fade_anim: AnimationPlayer = $CanvasLayer/FadeRect/FadeAnim

##########################
# 		CONSTANTS        #
##########################

const SPEED: float = 150.0
const JUMP_VELOCITY: float = -400.0
enum State { IDLE, WALK_LEFT, WALK_RIGHT, WALK_IN, WALK_OUT, INTERACT }

###########################
# 		PROPERTIES		  #
###########################

var current_state: State = State.IDLE
var last_state: State = State.IDLE
var energy: int = 10 # TODO balance this

func _ready() -> void:
	$CanvasLayer/FadeRect.show()
	play_fade("fade_out")
	fade_anim.connect("animation_finished", Callable(self, "_on_fade_finished"))

func _physics_process(delta: float) -> void:
	if not is_on_floor(): # gravity
		velocity += get_gravity() * delta
		
	if current_state == State.WALK_IN or current_state == State.WALK_OUT: # lock state
		move_and_slide()
		update_animation(current_state)
		return

	current_state = get_input()
	move_and_slide()
	update_audio(current_state)
	update_animation(current_state)

###
# @func get_input
# @return State
# Handles player input. In case of no input returns State.IDLE
func get_input() -> State:
	if Input.is_action_pressed("left"):
		velocity.x = -SPEED
		return State.WALK_LEFT
	elif Input.is_action_pressed("right"):
		velocity.x =  SPEED
		return State.WALK_RIGHT
	else:
		velocity.x = 0
		return State.IDLE

func walk_in() -> void:
	current_state = State.WALK_IN
	velocity = Vector2.ZERO
	sprite.play("walk_in")
	
	var animation = get_tree().create_tween()
	animation.tween_property(self, "scale", self.scale * 0.7, 0.7) # object, property, value, time
	animation.parallel().tween_property(self, "position:y", self.position.y - 15, 0.7)
	
	await animation.finished
	
func walk_out() -> void:
	current_state = State.WALK_OUT
	velocity = Vector2.ZERO
	sprite.play("walk_forward")
	
	var animation = get_tree().create_tween()
	animation.tween_property(self, "scale", self.scale * 1.3, 0.7) # object, property, value, time
	animation.parallel().tween_property(self, "position:y", self.position.y + 15, 0.7)
	
	await animation.finished
		
func update_animation(state: State):
	match state:
		State.WALK_LEFT:
			sprite.play("walk_left")
		State.WALK_RIGHT:
			sprite.play("walk_right")
		State.WALK_IN:
			sprite.play("walk_in")
		State.INTERACT:
			sprite.play("interact")
		State.IDLE:
			# Use the last walking direction to decide idle animation
			match last_state:
				State.WALK_LEFT:
					sprite.play("idle_left")
				State.WALK_RIGHT:
					sprite.play("idle_right")
				_:
					sprite.play("idle_right")

	# Update last_state if the player is walking
	if state in [State.WALK_LEFT, State.WALK_RIGHT]:
		last_state = state

########################
#	WORLD INTERACTION  #
########################
func play_fade(fade_type: String) -> void:
	$CanvasLayer/FadeRect.show()
	match fade_type:
		"fade_in":
			fade_anim.play("fade_in")
		"fade_out":
			fade_anim.play("fade_out")
		_:
			push_warning("Unknown fade_type: " + fade_type)

func init_landord_quest() -> void:
	pass

func init_tenant_quest() -> void:
	pass

######################
# 		AUDIO 		 #
######################
func update_audio(state: State) -> void:
	match state:
		State.WALK_LEFT, State.WALK_RIGHT:
			if audio.stream != walk_sound or not audio.playing:
				audio.stream = walk_sound
				audio.play()
		State.IDLE:
			if audio.stream == walk_sound and audio.playing:
				audio.stop()
		State.INTERACT:
			if audio.stream != interact_sound or not audio.playing:
				audio.stream = interact_sound
				audio.play()


func _on_audio_disable_pressed() -> void:
	pass # Replace with function body.
	
################
#    SLOTS     #
################
				
func _on_fade_finished(anim_name: String) -> void:
	if anim_name in ["fade_in", "fade_out"]:
		$CanvasLayer/FadeRect.hide()
