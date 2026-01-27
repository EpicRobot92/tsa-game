extends Node2D

const PLAYER_PREFAB := preload("res://scenes/Characters/player.tscn")

const STAGE_PREFABS := [
	preload("res://scenes/stage/stage_01.tscn"),
	preload("res://scenes/stage/stage_2.tscn"),
]
@onready var actors_container: Node2D = $ActorsContainer
@onready var camera: Camera2D = $Camera
@onready var fade_transition: fade_transition = $fade_transitionUI/Control/fade_transition
@onready var fade_timer: Timer = $fade_transitionUI/fade_timer
@onready var stage_container: Node2D = $StageContainer
@onready var menu_fade_timer: Timer = $Menu_Fade_Timer
@onready var music_container: Node2D = $Music




@onready var music_main: AudioStreamPlayer = $Music/GameplaySong
@onready var music_metronome: AudioStreamPlayer = $Music/MusicMetronome

var camera_initial_position := Vector2.ZERO
var music_metronme_vol : float
var is_camera_locked := false
var current_stage_index = -1
var is_stage_ready_for_loading = false
var player: Player = null
var player_died = false

func _ready() -> void:
	menu_fade_timer.timeout.connect(on_menu_fade_timer_timeout.bind())
	if is_stage_ready_for_loading: 
		is_stage_ready_for_loading = false
		var stage : Stage = STAGE_PREFABS[current_stage_index].instantiate()
		
	camera_initial_position = camera.position
	fade_timer.timeout.connect(On_Fade_Finished.bind())
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.stage_complete.connect(on_stage_complete)

	music_metronme_vol = music_metronome.volume_db
	music_metronome.volume_db = -80
	print("start")
	
	load_next_stage()
	
	

func find_child_of_type(parent_node):
	for child in parent_node.get_children():
		if child is Node2D: 
			return child
	return null

func Init_Music():
	BeatManager.clear_music_players(true)
	for Music in music_container.get_children(): 
			Music.queue_free()
	await get_tree().process_frame
	print(music_container.get_children())
	
	var stage = find_child_of_type(stage_container)
	var stage_music_container = stage.get_node("Music")
	for music in stage_music_container.get_children():
		music.reparent(music_container, true)
	
	
	music_main = music_container.get_node("GameplaySong")
	music_metronome = music_container.get_node("MusicMetronome")
	
	BeatManager.set_music_players([music_metronome, music_main])
	BeatManager.loop_songs = true
	BeatManager.start_songs()
	music_metronome.volume_db = -80 # mute
	

func _on_twin_swapped(new_twin: Player.Twin) -> void:
		if new_twin == Player.Twin.NOVA:
			music_metronome.volume_db = music_metronme_vol
		else:
			music_metronome.volume_db = -80
			
func on_stage_complete():
	fade_transition.fade_in(false)
	fade_timer.start()

		
func load_next_stage() -> void:
	current_stage_index += 1
	if current_stage_index < STAGE_PREFABS.size():
		for actor : Node2D in actors_container.get_children(): 
			actor.queue_free()
	
		for existing_stage in stage_container.get_children(): 
			existing_stage.queue_free()
			fade_transition.fade_out(true)
		

		is_stage_ready_for_loading = true
		
func on_checkpoint_start() -> void: 
	is_camera_locked = true
	
func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	is_camera_locked = false

## keeps the camera centered and also does not move back 
func _process(_delta: float) -> void:
	if is_stage_ready_for_loading: 
		is_stage_ready_for_loading = false
		var stage : Stage = STAGE_PREFABS[current_stage_index].instantiate()
		stage_container.add_child(stage)
		player = PLAYER_PREFAB.instantiate()
		actors_container.add_child(player)
		player.position = stage.get_player_spawn_location()
		actors_container.player = player
		EntityManager.twin_swapped.connect(_on_twin_swapped)
		camera.position = camera_initial_position
		camera.reset_smoothing()
		Init_Music()
		fade_transition.fade_out(true)
	
	if player and player.current_health <= 0 and not player_died:
		player_died = true
		fade_transition.fade_in(false) 
		menu_fade_timer.start()
		
	
	if player != null and not is_camera_locked and player.position.x > camera.position.x: 
		camera.position.x = player.position.x
		



	##When the Fade In finishes it starts the level
func On_Fade_Finished(): 
	load_next_stage()


func on_menu_fade_timer_timeout() -> void:
	print("menu")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
