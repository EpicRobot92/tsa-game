extends Node2D


@export var player : Player

const ENEMY_MAP := {
	Character.Type.BASIC_ENEMY: preload("res://scenes/Characters/basic_enemy.tscn")
}

func _ready() -> void:
	EntityManager.spawn_enemy.connect(on_spawn_enemy.bind())


func on_spawn_enemy(enemy_data: EnemyData) -> void:
	var enemy : Character = ENEMY_MAP[enemy_data.type].instantiate()
	enemy.global_position = enemy_data.global_position
	enemy.player = player
	add_child(enemy)
