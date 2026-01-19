extends Node2D

@onready var playerchar: CharacterBody2D = $ActorsContainer/Player
@onready var player: Player = $ActorsContainer/Player
@onready var camera: Camera2D = $Camera
@onready var fade_transition: fade_transition = $fade_transition

@onready var music_main: AudioStreamPlayer = $Music/GameplaySong
@onready var music_metronome: AudioStreamPlayer = $Music/MusicMetronome

var music_metronme_vol : float


func _ready() -> void:
	fade_transition.fade_out()
	player.twin_swapped.connect(_on_twin_swapped)
	music_metronme_vol = music_metronome.volume_db
	music_metronome.volume_db = -80
	print("start")
	BeatManager.set_music_players([music_metronome, music_main])
	BeatManager.loop_songs = true
	
	BeatManager.start_songs()

func _on_twin_swapped(new_twin: Player.Twin) -> void:
	if new_twin == Player.Twin.NOVA:
		music_metronome.volume_db = music_metronme_vol
	else:
		music_metronome.volume_db = -80
		


## keeps the camera centered and also does not move back 
func _process(_delta: float) -> void:
	if player.position.x > camera.position.x: 
		camera.position.x = player.position.x
	

		
