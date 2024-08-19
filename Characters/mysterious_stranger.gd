extends CharacterBody2D

enum char_state {idle, jump, run}

@export var move_speed: float = 100
@export var jump_height: float = 50
@export var jump_to_peak: float = 50
@export var jump_to_descent: float = 50

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var idle = $Idle
@onready var jump = $Jump
@onready var run = $Run
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_to_peak * jump_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_to_descent * jump_to_descent)) * -1.0

var move_direction : Vector2 = Vector2.ZERO
var current_sprite : Sprite2D = idle


func _ready():
	select_new_direction()
	
func select_new_direction():
	# we want our character to begin moving right
	move_direction = Vector2(1, 1)

func get_gravity_override() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _physics_process(delta):
	# Get input direction. Right is a positive value, and left is a negative value
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"), 0
	)
	var jump_direction = Vector2(0, Input.get_action_strength("jump"))
		
	if (input_direction.x < 0):
		current_sprite.flip_h = true
	elif (input_direction.x > 0):
		current_sprite.flip_h = false
	elif (jump_direction.y > 0):
		velocity.y = get_gravity_override() * delta
		char_jump(jump_direction)
	else:
		update_animation_params(input_direction)
	
	# update velocity
	velocity.x = input_direction.x * move_speed
	move_and_slide()
	pick_new_state()

func char_jump(jump_direction):
	velocity.y = jump_velocity
	update_animation_params(jump_direction)
	
func update_animation_params(move_input: Vector2):
	# Don't change params if there is no move input
	if (move_input.x != 0):
		animation_tree.set("parameters/Run/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
	elif(move_input.y > 0):
		animation_tree.set("parameters/Jump/blend_position", move_input)

# Choose state based on what is happening with the player
func pick_new_state():
	if (velocity.x != 0):
		state_machine.travel("Run")
		current_sprite = run
		run.show()
		jump.hide()
		idle.hide()
	elif (velocity.x == 0):
		state_machine.travel("Idle")
		current_sprite = idle
		idle.show()
		run.hide()
		jump.hide()
	elif (velocity.y < 0):
		state_machine.travel("Jump")
		current_sprite = jump
		idle.hide()
		run.hide()
		jump.show()
