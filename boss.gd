# Boss.gd
class_name Boss
extends Character

signal health_changed(current_health: int, max_health: int)
signal died
signal phase_changed(new_phase: int)
signal phase_hit_changed(current_hits: int, hits_needed: int)


enum Boss_State { IDLE, COOLDOWN, ATTACK }


@export var player: Player
@export var invulnerable: bool = false
@export var cooldown_duration: float = 1.5

@export var max_phase: int = 2
@export var hits_per_phase: int = 3
@export var damage_per_hit: int = 15


var phase: int = 1
var phase_hits: int = 0

var is_dead: bool = false
var boss_state: Boss_State = Boss_State.IDLE
var cooldown_time: float = 0.0


func _ready() -> void:
	super._ready()


func _process(delta: float) -> void:
	if is_dead:
		return

	match boss_state:
		Boss_State.IDLE:
			start_attack()

		Boss_State.ATTACK:
			attack()

		Boss_State.COOLDOWN:
			cooldown_time -= delta
			if cooldown_time <= 0:
				boss_state = Boss_State.IDLE


func on_receive_damage(
	amount: int,
	direction: Vector2 = Vector2.ZERO,
	hit_type = null,
	knockback: float = 0.0
) -> void:
	print("Damage")
	print("Current Health:", current_health)

	if invulnerable or is_dead:
		return

	# Damage health normally.
	set_health(current_health - damage_per_hit)
	current_health = max(current_health, 0)

	phase_hits += 1
	phase_hit_changed.emit(phase_hits, hits_per_phase)
	health_changed.emit(current_health, max_health)

	print("Phase:", phase, "Phase Hits:", phase_hits, "/", hits_per_phase)

	if current_health <= 0:
		EntityManager.death_enemy.emit(self)
		damage_receiver.monitoring = false
		die()
		return

	if phase_hits >= hits_per_phase:
		advance_phase()
	else:
		# Still same phase, but boss should stop being hittable again.
		invulnerable = true
		boss_state = Boss_State.ATTACK


func advance_phase() -> void:
	phase_hits = 0

	if phase >= max_phase:
		EntityManager.death_enemy.emit(self)
		damage_receiver.monitoring = false
		die()
		return

	phase += 1
	phase_changed.emit(phase)
	on_phase_changed(phase)

	print("Advanced to phase:", phase)

	invulnerable = true
	boss_state = Boss_State.ATTACK


func start_attack() -> void:
	boss_state = Boss_State.ATTACK


func become_vulnerable() -> void:
	boss_state = Boss_State.IDLE
	invulnerable = false


func attack() -> void:
	match phase:
		1:
			print("phase 1 attack")
		2:
			print("phase 2 attack")

	enter_cooldown()


func enter_cooldown() -> void:
	cooldown_time = cooldown_duration
	boss_state = Boss_State.COOLDOWN


func on_phase_changed(new_phase: int) -> void:
	pass


func die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit()
	queue_free()
