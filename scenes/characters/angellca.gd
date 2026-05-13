extends "res://scenes/characters/evangeline.gd"

@export var EnemySpawn : Node2D


func _ready() -> void:
	super._ready()
	normal_alpha = modulate.a
	invulnerable = true
	BeatManager.beat.connect(on_beat)


func _process(delta: float) -> void:
	if is_dead:
		return
	
	if is_vulnerable_window:
		handle_vulnerable_window(delta)
		return
	
	super._process(delta)


func attack() -> void:
	if waiting_for_beat or is_vulnerable_window:
		return
		
	print("Boss is waiting for beat...")
	waiting_for_beat = true


func on_beat(current_beat_index: int) -> void:
	if not waiting_for_beat:
		return
	
	if is_vulnerable_window:
		return
	
	waiting_for_beat = false
	
	match phase:
		1:
			phase_1_attack()
		2:
			phase_2_attack()


func phase_1_attack() -> void:
	print("phase 1 shockwave")
	shockwave_attack()
	move_hover_step()
	finish_attack()


func phase_2_attack() -> void:
	print("phase 2 shockwave")
	shockwave_attack()
	await get_tree().create_timer(0.05).timeout
	shockwave_attack()
	move_hover_step()
	finish_attack()




func on_phase_changed(new_phase: int) -> void:
	print("Evangeline entered phase:", new_phase)
	
	attack_count = 0
	hover_step_count = 0
	hover_direction = -1
	waiting_for_beat = false
	is_vulnerable_window = false
	invulnerable = true
	modulate.a = normal_alpha
	enter_cooldown()


func shockwave_attack() -> void:
	print("shock")

	EntityManager.spawn_projectile(
		shockwave_projectile_scene,
		attack_1_pos.global_position,
		Vector2.LEFT,
		null,
		{
			"damage": damage,
			"speed": 500.0,
			"knockback": 250.0
		}
	)


func move_hover_step() -> void:
	global_position.y += hover_direction * hover_step_distance
	
	hover_step_count += 1
	
	if hover_step_count >= 3:
		hover_step_count = 0
		hover_direction *= -1


func finish_attack() -> void:
	attack_count += 1
	
	if attack_count >= attacks_before_vulnerable:
		start_vulnerable_window()
	else:
		invulnerable = true
		enter_cooldown()


func start_vulnerable_window() -> void:
	print("Boss is vulnerable!")
	
	attack_count = 0
	waiting_for_beat = false
	is_vulnerable_window = true
	vulnerable_time_left = vulnerable_duration
	
	invulnerable = false
	boss_state = Boss_State.IDLE


func handle_vulnerable_window(delta: float) -> void:
	vulnerable_time_left -= delta
	
	# Fade toward the vulnerable alpha.
	modulate.a = move_toward(modulate.a, vulnerable_alpha, delta * alpha_fade_speed)
	
	if vulnerable_time_left <= 0:
		end_vulnerable_window()


func end_vulnerable_window() -> void:
	print("Boss is no longer vulnerable!")
	
	is_vulnerable_window = false
	invulnerable = true
	
	# Restore opacity.
	modulate.a = normal_alpha
	
	enter_cooldown()
