extends "res://scenes/characters/evangeline.gd"

@export var EnemySpawn: Node2D
@export var enemies_per_wave: int = 3

@export var vulnerable_flicker_speed := 12.0
@export var vulnerable_flicker_min_alpha := 0.35

var active_enemy_counter := 0
var spawning_wave := false
var vulnerable_flicker_time := 0.0


func _ready() -> void:
	super._ready()
	
	normal_alpha = modulate.a
	invulnerable = true
	
	EntityManager.death_enemy.connect(on_enemy_death)


func _process(delta: float) -> void:
	if is_dead:
		return
	
	if is_vulnerable_window:
		handle_vulnerable_window(delta)
		return
	
	super._process(delta)


func attack() -> void:
	if waiting_for_beat or is_vulnerable_window or spawning_wave:
		return
		
	print("Boss is waiting for beat...")
	waiting_for_beat = true


func on_beat(current_beat_index: int) -> void:
	if not waiting_for_beat:
		return
	
	if is_vulnerable_window or spawning_wave:
		return
	
	waiting_for_beat = false
	
	match phase:
		1:
			phase_1_attack()
		2:
			phase_2_attack()


# =========================
# PHASES
# =========================

func phase_1_attack() -> void:
	if spawning_wave:
		return
	
	print("Angelica spawning enemy wave...")
	
	spawning_wave = true
	spawn_enemy_wave()
	
	invulnerable = false
	start_vulnerable_window()


func phase_2_attack() -> void:
	print("phase 2 shockwave")
	
	shockwave_attack()
	
	await get_tree().create_timer(0.05).timeout
	
	shockwave_attack()
	
	finish_attack()


func spawn_enemy_wave() -> void:
	active_enemy_counter = enemies_per_wave
	
	for i in range(enemies_per_wave):
		var enemy_type = [
			Character.Type.BASIC_ENEMY,
			Character.Type.DASH_ENEMY,
			Character.Type.ELITE_DASHER_ENEMY
		].pick_random()
		
		EntityManager.spawn_boss_enemy.emit(
			enemy_type,
			EnemySpawn.global_position,
			player
		)


func on_enemy_death(enemy: Character) -> void:
	if not spawning_wave:
		return
	
	if enemy.type == Character.Type.ANGELICA:
		return
	
	active_enemy_counter -= 1
	
	print("Wave enemies left:", active_enemy_counter)
	
	if active_enemy_counter <= 0:
		end_enemy_wave()


func end_enemy_wave() -> void:
	print("Enemy wave complete!")
	
	spawning_wave = false
	
	end_vulnerable_window()


# =========================
# PHASE CHANGES
# =========================

func on_phase_changed(new_phase: int) -> void:
	print("Angelica entered phase:", new_phase)
	
	attack_count = 0
	hover_step_count = 0
	hover_direction = -1
	
	waiting_for_beat = false
	is_vulnerable_window = false
	spawning_wave = false
	vulnerable_flicker_time = 0.0
	
	invulnerable = true
	modulate.a = normal_alpha
	
	enter_cooldown()


# =========================
# ATTACKS
# =========================

func shockwave_attack() -> void:
	print("shock")

	EntityManager.spawn_projectile(
		shockwave_projectile_scene,
		attack_1_pos.global_position,
		Vector2.DOWN,
		null,
		{
			"damage": damage,
			"speed": 500.0,
			"knockback": 250.0
		}
	)


# =========================
# ATTACK LOOP
# =========================

func finish_attack() -> void:
	attack_count += 1
	
	if attack_count >= attacks_before_vulnerable:
		start_vulnerable_window()
	else:
		invulnerable = true
		enter_cooldown()


# =========================
# VULNERABILITY
# =========================

func start_vulnerable_window() -> void:
	print("Boss is vulnerable!")
	
	attack_count = 0
	waiting_for_beat = false
	
	is_vulnerable_window = true
	vulnerable_time_left = vulnerable_duration
	vulnerable_flicker_time = 0.0
	
	invulnerable = false
	boss_state = Boss_State.IDLE


func handle_vulnerable_window(delta: float) -> void:
	vulnerable_time_left -= delta
	vulnerable_flicker_time += delta
	
	var flicker_value = (sin(vulnerable_flicker_time * vulnerable_flicker_speed) + 1.0) / 2.0
	
	modulate.a = lerp(
		vulnerable_flicker_min_alpha,
		normal_alpha,
		flicker_value
	)
	
	if vulnerable_time_left <= 0:
		end_vulnerable_window()


func end_vulnerable_window() -> void:
	print("Boss is no longer vulnerable!")
	
	is_vulnerable_window = false
	invulnerable = true
	vulnerable_flicker_time = 0.0
	
	modulate.a = normal_alpha
	
	enter_cooldown()
