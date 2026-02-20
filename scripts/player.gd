extends CharacterBody3D


@onready var sfx_jump: AudioStreamPlayer3D = $sfx_jump
@onready var sfx_dash: AudioStreamPlayer3D = $sfx_dash


# camera and head
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

# movement variables
@export var walking_speed : float = 6.0
@export var sprinting_speed : float = 11.0
@export var slide_speed : float = 24.0
@export var jump_velocity : float = 5.0

@export var jump_velocity_wall : float = 20.0

# acceleration variables, very annoying probably redundant
@export var ground_acceleration : float = 25.0
@export var air_acceleration : float = 8.0
@export var friction : float = 8.0
@export var gravity_multiplier : float = 1.0

# dash variables
@export var dash_speed : float = 25.0
@export var dash_duration : float = 0.2
@export var dash_cooldown : float = 0.4


# camera tilt variables
@export var max_tilt_angle : float = 5.0
@export var tilt_speed : float = 15.0
@export var slide_tilt_multiplier : float = 1.8


# mouse sensitivity, not changable yet
const mouse_sens = 0.4

# other variables 
var current_speed : float
var sliding = false
var is_dashing = false
var can_dash = true
var jumps_left = 2
var max_jumps = 2
var dashes_left = 3
# sets current camera tilt to zero obviously thats the basic !

var current_tilt : float = 0.0

# also dash timer. who did this
@onready var dash_timer = Timer.new()
@onready var dash_cooldown_timer = Timer.new()

# function ready, everything uh.. guh... gets ready
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)

	add_child(dash_cooldown_timer)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)

# inputs
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# physics
func _physics_process(delta: float) -> void:

	# gravity
	if not is_on_floor():
		velocity.y -= 9.8 * gravity_multiplier * delta
		
#reset jumps to 2 when you touch the floor
	if is_on_floor():
		jumps_left = max_jumps
	
	# jump wall
	if Input.is_action_just_pressed("jump") and jumps_left > 0 and is_on_wall():
		jumps_left -= 1 
		velocity.y += jump_velocity_wall
		sfx_jump.pitch_scale = 1.1
		sfx_jump.play() 
		
	# jump
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1
		sfx_jump.pitch_scale = 1 
		sfx_jump.play()
		
		# slide jump carries momentum. this shit gets crazy
		if sliding:
			velocity.x *= 1.7
			velocity.z *= 1.7

	# dashing
	if Input.is_action_just_pressed("dash") and can_dash and not sliding:
		start_dash()

	# movement
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


	if Input.is_action_pressed("slide") and is_on_floor() and not is_dashing:

		if not sliding:
			sliding = true
		current_speed = slide_speed
		velocity.x = move_toward(velocity.x, move_dir.x * slide_speed, 4.0 * delta)
		velocity.z = move_toward(velocity.z, move_dir.z * slide_speed, 4.0 * delta)

	else:
		sliding = false

		if not is_dashing:
			current_speed = sprinting_speed if Input.is_action_pressed("sprint") else walking_speed

			var target_velocity = move_dir * current_speed
			var accel = ground_acceleration if is_on_floor() else air_acceleration

			velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
			velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)

			# friction on ground
			if move_dir == Vector3.ZERO and is_on_floor():
				velocity.x = move_toward(velocity.x, 0, friction * delta)
				velocity.z = move_toward(velocity.z, 0, friction * delta)

	# this handles the camera tilt itself
	handle_camera_tilt(delta)

	move_and_slide()


func start_dash():
	is_dashing = true
	can_dash = false

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var dash_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if dash_dir == Vector3.ZERO and dashes_left > 0:
		dash_dir = -head.global_transform.basis.z
		
	velocity.x = dash_dir.x * dash_speed
	velocity.z = dash_dir.z * dash_speed
	
	sfx_dash.play()

	
	dash_timer.start(dash_duration)

func _on_dash_timer_timeout():
	is_dashing = false
	dash_cooldown_timer.start(dash_cooldown)

func _on_dash_cooldown_timeout():
	can_dash = true


func handle_camera_tilt(delta):

	# instant input-based strafe detection
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var normalized_strafe = input_dir.x  # Immediate response

	# target tilt
	var target_tilt = -normalized_strafe * max_tilt_angle

	# stronger tilt while sliding
	if sliding:
		target_tilt *= slide_tilt_multiplier

	current_tilt = lerp(current_tilt, target_tilt, 1.0 - exp(-tilt_speed * delta))

	camera_3d.rotation_degrees.z = current_tilt


	if Input.is_action_just_pressed("upgrade_test"):
			dash_speed += 3
			
	if Input.is_action_just_pressed("upgrade_test"):
			max_jumps += 1 
			
	if Input.is_action_just_pressed("upgrade_test"):
			jump_velocity += 1 
