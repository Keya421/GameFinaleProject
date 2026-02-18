extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D


var current_speed = 5.0
var walking_speed = 5.0
var sprinting_speed = 10.0
var crouching_speed = 3.0
var sliding_speed = 9.0
var jump_velocity = 4.5
var sliding = false

const mouse_sens = 0.4

var lerp_speed = 10.0

var direction = Vector3.ZERO
## captures the sly mouse
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
## mouse motion
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("sprint"):
		current_speed = sprinting_speed
	else:
		current_speed = walking_speed
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
