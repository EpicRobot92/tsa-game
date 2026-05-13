extends Node2D


@export var player : Player

const ENEMY_MAP := {
	Character.Type.BASIC_ENEMY: preload("res://scenes/characters/basic_enemy.tscn"),
	Character.Type.DASH_ENEMY: preload("res://scenes/characters/dash_enemy.tscn"),
	Character.Type.ELITE_DASHER_ENEMY: preload("res://scenes/characters/elite_dash_enemy.tscn"),
	Character.Type.EVANGELINE: preload("res://scenes/characters/Evangeline.tscn"),
	Character.Type.ANGELICA: preload("res://scenes/characters/angellca.tscn"),
	
}

func _ready() -> void:
	EntityManager.spawn_enemy.connect(on_spawn_enemy.bind())


func on_spawn_enemy(enemy_data: EnemyData) -> void:
	print("Spawning enemy type:", enemy_data.type)
	print("Enemy map keys:", ENEMY_MAP.keys())

	if not ENEMY_MAP.has(enemy_data.type):
		push_error("No enemy scene found for enemy type: " + str(enemy_data.type))
		return

	var enemy_scene: PackedScene = ENEMY_MAP[enemy_data.type]
	var enemy: Character = enemy_scene.instantiate()
	enemy.global_position = enemy_data.global_position
	enemy.player = player
	add_child(enemy)
