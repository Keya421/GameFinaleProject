extends Camera3D
# camera fov variables
@export var default_fov: float = 90.0 # Normal FOV value
@export var dash_fov: float = 120.0   # Target FOV when sprinting
@export var slide_fov: float = 150.0     # Speed of the FOV transition
@export var fov_speed: float = 2.0     # Speed of the FOV transition

# @onready var player: CharacterBody3D = $"../../.." 
var target_fov: float = default_fov
##var velocity = player.velocity
##var speed = velocity.length() 

func _process(delta: float) -> void:
	if Input.is_action_pressed("dash"):
		target_fov = dash_fov
	else:
		target_fov = default_fov
		
	self.fov = lerpf(self.fov, target_fov, delta * fov_speed)
	
	if Input.is_action_pressed("slide"):
		target_fov = slide_fov
	else:
		target_fov = default_fov
		
	self.fov = lerpf(self.fov, target_fov, delta * fov_speed)
