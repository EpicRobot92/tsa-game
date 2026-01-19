extends Node2D

@onready var player: CharacterBody2D = $ActorsContainer/Player
@onready var camera: Camera2D = $Camera

@onready var music_main: AudioStreamPlayer = $Music/GameplaySong
@onready var music_metronome: AudioStreamPlayer = $Music/MusicMetronome


func _ready() -> void:
	print("start")
	BeatManager.set_music_players([music_metronome, music_main])
	BeatManager.loop_songs = true
	
	BeatManager.start_songs()


## keeps the camera centered and also does not move back 
func _process(_delta: float) -> void:
	if player.position.x > camera.position.x: 
		camera.position.x = player.position.x
		
