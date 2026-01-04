extends Node2D

@onready var player: CharacterBody2D = $ActorsContainer/Player
@onready var camera: Camera2D = $Camera


## keeps the camera centered and also does not move back 
func _process(_delta: float) -> void:
	if player.position.x > camera.position.x: 
		camera.position.x = player.position.x
