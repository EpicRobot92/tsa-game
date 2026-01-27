class_name Stage
extends Node2D

@onready var checkpoints: Node2D = $Checkpoints


var music_metronme_vol : float

@onready var player_spawn_location: Node2D = $PlayerSpawnLocation

func _init() -> void:
	print("init")
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())

func get_player_spawn_location() -> Vector2:
	return player_spawn_location.position



func on_checkpoint_complete(checkpoint: Checkpoint) -> void: 
	print("check")
	if checkpoints.get_child(-1) == checkpoint:
		print("last")
		StageManager.stage_complete.emit()
