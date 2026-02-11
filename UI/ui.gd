class_name UI
extends CanvasLayer



@onready var player_healthbar: Healthbar = $UIContainer/PlayerHealthBar
@onready var enemy_health_bar: Healthbar = $UIContainer/EnemyHealthBar
@onready var enemy_avatar: TextureRect = $UIContainer/EnemyAvatar
@onready var player_avatar: TextureRect = $UIContainer/PlayerAvatar
@onready var beat_pulse: ColorRect = $UIContainer/BeatPulse
@onready var tutorial_text: animated_text = $UIContainer/Tutorial_Text
@onready var onward_arrow: Sprite2D = $UIContainer/OnwardArrow
@onready var Onward_animation_player: AnimationPlayer = $UIContainer/OnwardArrow/AnimationPlayer
@onready var pause_music: AudioStreamPlayer2D = $PauseMusic

@onready var pause_menu: Control = $UIContainer/PauseMenu

@onready var resume: Button = $UIContainer/PauseMenu/Resume
@onready var main_menu: Button = $UIContainer/PauseMenu/MainMenu

@onready var fade_transition = $UIContainer/fade_transitionUI/Control/fade_transition


@export var duration_healthbar_visible : int 


var time_start_healthbar_visible := Time.get_ticks_msec()


var paused = false

const avatar_map : Dictionary = {
	Character.Type.BASIC_ENEMY: preload("res://assets/art/ui/avatars/Avatar_Basic_Enemy.png"),
	Character.Type.DASH_ENEMY: preload("res://assets/art/ui/avatars/Avatar_Dasher_Enemy.png"),
	Character.Type.ELITE_DASHER_ENEMY: preload("res://assets/art/ui/avatars/Avatar_Elite_Dasher_Enemy.png")
}

const player_map : Dictionary = {
	Player.Twin.ECLIPTIO: preload("res://assets/art/ui/avatars/Avatar_Ecliptio.png"),
	Player.Twin.NOVA: preload("res://assets/art/ui/avatars/avatar_Nova.png"),
}






func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())

func _ready() -> void: 
	EntityManager.twin_swapped.connect(on_twin_swap.bind())
	StageManager.show_tutorial_prompt.connect(On_tutorial_prompt.bind())
	onward_arrow.visible = false
	enemy_avatar.visible = false
	enemy_health_bar.visible = false
	beat_pulse.visible = false
	
func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	Onward_animation_player.play("Onward!")

func On_tutorial_prompt(index):
	if index != 8: 
		tutorial_text.change_text(index)
	else: 
		tutorial_text.hide_text()
		
func Resume() -> void: 
	pause_menu.visible = false
	get_tree().paused = false
	pause_music.stop()

func handle_input() -> void: 
	if Input.is_action_just_pressed("Pause"): 
		if paused: 
			paused = false
			Resume()
		else:
			paused = true
			pause()
	if Input.is_action_just_pressed("resume"): 
		Resume()
		

func pause(): 
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu.visible = true
	get_tree().paused = true
	pause_music.play()
	
	




func _process(_delta: float) -> void:
	handle_input()
	if enemy_health_bar.visibility_layer and (Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible):
		enemy_avatar.visible = false
		enemy_health_bar.visible = false

func on_twin_swap(twin : Player.Twin): 
	player_avatar.texture = player_map[twin]
	beat_pulse.visible = true if twin == Player.Twin.NOVA else false
	



func on_character_health_change(type: Character.Type, current_health: int, max_health: int):
	if not player_healthbar: return on_character_health_change(type, current_health, max_health)
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
	else:
		time_start_healthbar_visible = Time.get_ticks_msec()
		enemy_avatar.texture = avatar_map[type]
		enemy_health_bar.refresh(current_health, max_health)
		enemy_avatar.visible = true
		enemy_health_bar.visible = true


func _on_resume_pressed() -> void:
	Resume()


func _on_main_menu_pressed() -> void:
	fade_transition.fade_in(false)
	await fade_transition.animation_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
