extends Node

signal death_enemy(enemy: Character)
signal spawn_enemy(enemy_data: EnemyData)
signal spawn_boss_enemy(type : int, position : Vector2, player : Player)

signal twin_swapped(new_twin: Player.Twin)
signal Player_Acted(state : Player.State)

const ENEMY_MAP := {
	Character.Type.BASIC_ENEMY: preload("res://scenes/characters/basic_enemy.tscn")
}




func spawn_projectile(
	projectile_scene: PackedScene,
	pos: Vector2,
	dir: Vector2,
	target: Node2D = null,
	config: Dictionary = {}
) -> Node:
	var p = projectile_scene.instantiate()
	p.global_position = pos

	
	for k in config.keys():
		if k in p:
			p.set(k, config[k])

	if target:
		p.setup_target(target)
	else:
		p.setup_direction(dir)

	get_tree().current_scene.get_node("ActorsContainer").add_child(p)
	return p
