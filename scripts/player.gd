extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

@export var speed : float = 5.0
@export var dash_speed : float = 20.0
@export var dash_duration : float = 0.2
@export var dash_cooldown : float = 1.0


var current_speed = 5.0
var walking_speed = 5.0
var sprinting_speed = 10.0
var crouching_speed = 3.0
var jump_velocity = 4.5
var fall_distance = 0

var can_slide = false
var sliding = false
var slide_speed = 9.0
var slide_timer = 3.0

@onready var slide_check = $Slide_Check

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
		
	if Input.is_action_just_pressed("slide") and current_speed > 3:
		can_slide = true
		
	if Input.is_action_just_pressed("slide") and is_on_floor() and Input.is_action_pressed("up") and can_slide:
		slide()
		
	if Input.is_action_just_released("slide"):
		can_slide = false
		sliding = false
		


func slide():
	if not sliding:
		if slide_check.is_colliding() or get_floor_angle() < 0.2:
			slide_speed = 5
			slide_speed += fall_distance / 10
		else:
			slide_speed = 2
	sliding = true
	
	if slide_check.is_colliding():
		slide_speed += get_floor_angle() / 10
	else:
		slide_speed -= (get_floor_angle() / 5) + 0.03
	if slide_speed < 0:
		can_slide = false
		sliding = false
		
	speed = slide_speed

	move_and_slide()
	
	
