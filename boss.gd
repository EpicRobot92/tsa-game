# Boss.gd
class_name Boss
extends Node2D

signal health_changed(current_health: int, max_health: int)
signal died
signal phase_changed(new_phase: int)

enum Type { EVANGELINE, EDEN, ANGELICA }
enum State { IDLE, COOLDOWN, ATTACK }

@export var type: Type
@export var max_health: int = 3
@export var invulnerable: bool = false
@export var cooldown_duration: float = 1.5

var health: int
var phase: int = 1
var is_dead: bool = false
var state: State = State.IDLE
var cooldown_time: float = 0.0


func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)


func _process(delta: float) -> void:
	if is_dead:
		return

	match state:
		State.IDLE:
			start_attack()

		State.ATTACK:
			attack()

		State.COOLDOWN:
			cooldown_time -= delta
			if cooldown_time <= 0:
				state = State.IDLE


func on_receive_damage(amount: int, direction: Vector2 = Vector2.ZERO, hit_type = null, knockback: float = 0.0) -> void:
	if invulnerable or is_dead:
		return

	health -= 1
	health = max(health, 0)

	health_changed.emit(health, max_health)

	if health <= 0:
		die()
		return

	phase += 1
	phase_changed.emit(phase)
	on_phase_changed(phase)

	invulnerable = true
	state = State.ATTACK


func start_attack() -> void:
	state = State.ATTACK

func become_vulnerable() -> void:
	state = State.IDLE
	invulnerable = false


func attack() -> void:
	match phase:
		1:
			print("phase 1 attack")
		2:
			print("phase 2 attack")
		3:
			print("phase 3 attack")

	enter_cooldown()



func enter_cooldown() -> void:
	cooldown_time = cooldown_duration
	state = State.COOLDOWN


func on_phase_changed(new_phase: int) -> void:
	pass


func die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit()
	queue_free()
