class_name UI
extends CanvasLayer



@onready var player_healthbar: Healthbar = $UIContainer/PlayerHealthBar
@onready var enemy_health_bar: Healthbar = $UIContainer/EnemyHealthBar
@onready var enemy_avatar: TextureRect = $UIContainer/EnemyAvatar
@onready var player_avatar: TextureRect = $UIContainer/PlayerAvatar
@onready var beat_pulse: ColorRect = $UIContainer/BeatPulse


@export var duration_healthbar_visible : int 


var time_start_healthbar_visible := Time.get_ticks_msec()

const avatar_map : Dictionary = {
	Character.Type.BASIC_ENEMY: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.DASH_ENEMY: preload("res://assets/art/ui/avatars/avatar-goon.png"),
}

const player_map : Dictionary = {
	Player.Twin.ECLIPTIO: preload("res://assets/art/ui/avatars/avatar-player.png"),
	Player.Twin.NOVA: preload("res://assets/art/ui/avatars/avatar-punk.png"),
}


func _init() -> void:
	
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())

func _ready() -> void: 
	EntityManager.twin_swapped.connect(on_twin_swap.bind())
	enemy_avatar.visible = false
	enemy_health_bar.visible = false
	beat_pulse.visible = false
	
func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	pass

func _process(_delta: float) -> void:
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
