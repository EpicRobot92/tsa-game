class_name DashEnemy
extends BasicEnemy


@export var too_close_dist: float = 28.0         # if closer than this, back off first
@export var dash_start_dist: float = 85.0        # distance we want before dashing
@export var dash_trigger_dist: float = 95.0      # once we reach this, start windup+dash
@export var retreat_speed_mult: float = 1.1

@export var windup_ms: int = 160
@export var dash_ms: int = 220
@export var dash_speed: float = 320.0
@export var recover_ms: int = 320

# only let dash happen when player is alive + attack cooldown ready
@export var require_can_attack: bool = true

enum DashState { CHASE, RETREAT, WINDUP, DASH, RECOVER }
var dash_state: int = DashState.CHASE

var dash_dir := Vector2.ZERO
var state_start_ms := 0

func _ready() -> void:
	super._ready()


func handle_input() -> void:
	if player == null or not can_move():
		return

	if player_slot == null:
		player_slot = player.reserve_slot(self)
	if player_slot == null:
		return

	var to_slot := player_slot.global_position - global_position
	var dist := to_slot.length()
	var dir := to_slot.normalized()

	match dash_state:
		DashState.CHASE:
			# If dashman too close, back off to be fair
			if dist <= too_close_dist:
				_start_retreat(-dir)
				return

			# Normal move toward our slot (but stop when in dash range)
			if dist > dash_trigger_dist:
				velocity = dir * speed
			else:
				velocity = Vector2.ZERO
				# Begin windup/dash if allowed
				if player.current_health > 0 and (not require_can_attack or can_attack()):
					_start_windup(dir)
			return

		DashState.RETREAT:
			# Move away until we reach the "dash start distance"
			velocity = dash_dir * (speed * retreat_speed_mult)
			if dist >= dash_start_dist:
				# once spaced, immediately prep dash
				velocity = Vector2.ZERO
				if player.current_health > 0 and (not require_can_attack or can_attack()):
					_start_windup(dir)
				else:
					dash_state = DashState.CHASE
			return

		DashState.WINDUP:
			velocity = Vector2.ZERO
			if Time.get_ticks_msec() - state_start_ms >= windup_ms:
				_start_dash()
			return

		DashState.DASH:
			velocity = dash_dir * dash_speed
			if Time.get_ticks_msec() - state_start_ms >= dash_ms:
				_start_recover()
			return
		# time after dash
		DashState.RECOVER:
			velocity = Vector2.ZERO
			if Time.get_ticks_msec() - state_start_ms >= recover_ms:
				dash_state = DashState.CHASE
			return


func _start_retreat(retreat_dir: Vector2) -> void:
	dash_state = DashState.RETREAT
	dash_dir = retreat_dir
	state_start_ms = Time.get_ticks_msec()


func _start_windup(dir_to_player: Vector2) -> void:
	state = State.PREP_ATTACK
	dash_state = DashState.WINDUP
	dash_dir = dir_to_player
	state_start_ms = Time.get_ticks_msec()

	# start cooldown so it can't spam
	time_since_last_hit = Time.get_ticks_msec()
	time_since_prep_hit = Time.get_ticks_msec()



func _start_dash() -> void:
	state = State.ATTACK
	dash_state = DashState.DASH
	state_start_ms = Time.get_ticks_msec()



func _start_recover() -> void:
	dash_state = DashState.RECOVER
	state_start_ms = Time.get_ticks_msec()
	velocity = Vector2.ZERO
