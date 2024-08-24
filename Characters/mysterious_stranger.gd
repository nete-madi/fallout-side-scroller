extends CharacterBody2D

@export var move_speed: float = 200
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

const JUMP_VELOCITY = -400.0

var current_sprite : Sprite2D = idle

func _physics_process(delta: float) -> void:
	var run_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"), 0
	)
	if (run_direction.x < 0):
		current_sprite.flip_h = true
	elif (run_direction.x > 0):
		current_sprite.flip_h = false
	update_animation_params(run_direction)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# update velocity
	velocity.x = run_direction.x * move_speed
	move_and_slide()
	pick_new_state()

func update_animation_params(move_input: Vector2):
	# Don't change params if there is no move input
	print(move_input)
	if (move_input.x != 0):
		animation_tree.set("parameters/Run/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

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
	if (velocity.y < 0):
		state_machine.travel("Jump")
		current_sprite = jump
		idle.hide()
		run.hide()
		jump.show()
	if (velocity.y > 0):
		state_machine.travel("Fall")
		current_sprite = jump
		idle.hide()
		run.hide()
		jump.show()
