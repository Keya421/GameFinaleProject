extends Label
@onready var speedometer: Label = $"../speedometer"
@onready var player: CharacterBody3D = $"../../.." 

var drain_rate : float = 10.0
var gain_rate : float = 1.0
var health : float = 100.0

func _process(_delta: float) -> void:
	
	var velocity = player.velocity
	var speed = velocity.length() 
	text = "Health: " + str(int(health))
	
	if speed < 1.0 and health > 0:
		health -= drain_rate * _delta
	
	if speed > 10.0 and health > 0:
		health += gain_rate * _delta
		
	if health < 1:
		get_tree().quit()
		
	health = clamp(health, 0.0, 100.0)
	
	text = "Health: " + str(int(health))
