extends Node

signal death_enemy(enemy: Character)
signal spawn_enemy(enemy_data: EnemyData)

const ENEMY_MAP := {
	Character.Type.BASIC_ENEMY: preload("res://scenes/Characters/basic_enemy.tscn")
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

	# Apply config overrides (damage, speed, lifetime, etc.)
	for k in config.keys():
		if k in p:
			p.set(k, config[k])

	if target:
		p.setup_target(target)
	else:
		p.setup_direction(dir)

	get_tree().current_scene.get_node("ActorsContainer").add_child(p)
	return p
