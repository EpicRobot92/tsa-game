extends Node

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

	get_tree().current_scene.add_child(p)
	return p
