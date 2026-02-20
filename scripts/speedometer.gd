extends Label

# Reference to the player node
@onready var player: CharacterBody3D = $"../../.." 

func _process(_delta: float) -> void:
	var velocity = player.velocity
	
	var speed = velocity.length() 
	
	text = "Speed: " + str(int(speed))
