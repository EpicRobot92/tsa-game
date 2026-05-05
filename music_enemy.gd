extends BasicEnemy
class_name SHOOTEnemy



@export var too_close_dist: float = 28.0         # if closer than this, back off first
@export var SHOOT_start_dist: float = 85.0        # distance we want before SHOOTing
@export var SHOOT_trigger_dist: float = 95.0      # once we reach this, start windup+SHOOT
@export var retreat_speed_mult: float = 1.1

@export var windup_ms: int = 160
@export var SHOOT_ms: int = 220
@export var SHOOT_speed: float = 320.0
@export var recover_ms: int = 320


# only let SHOOT happen when player is alive + attack cooldown ready
@export var require_can_attack: bool = true

enum MusicState { CHASE, RETREAT, WINDUP, SHOOT, RECOVER }
var music_state: int = MusicState.CHASE

var SHOOT_dir := Vector2.ZERO
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

	match music_state:
		MusicState.CHASE:
			# If SHOOTman too close, back off to be fair
			if dist <= too_close_dist:
				_start_retreat(-dir)
				return

			# Normal move toward our slot (but stop when in SHOOT range)
			if dist > SHOOT_trigger_dist:
				velocity = dir * speed
			else:
				velocity = Vector2.ZERO
				# Begin windup/SHOOT if allowed
				if player.current_health > 0 and (not require_can_attack or can_attack()):
					_start_windup(dir)
			return

		MusicState.RETREAT:
			# Move away until we reach the "SHOOT start distance"
			velocity = SHOOT_dir * (speed * retreat_speed_mult)
			if dist >= SHOOT_start_dist:
				# once spaced, immediately prep SHOOT
				velocity = Vector2.ZERO
				if player.current_health > 0 and (not require_can_attack or can_attack()):
					_start_windup(dir)
				else:
					music_state = MusicState.CHASE
			return

		MusicState.WINDUP:
			velocity = Vector2.ZERO
			if Time.get_ticks_msec() - state_start_ms >= windup_ms:
				_start_SHOOT()
			return

		MusicState.SHOOT:
			velocity = SHOOT_dir * SHOOT_speed
			damage_emmiter.monitoring = true
			if Time.get_ticks_msec() - state_start_ms >= SHOOT_ms:
				_start_recover()
				damage_emmiter.monitoring = false
			return
		# time after SHOOT
		MusicState.RECOVER:
			velocity = Vector2.ZERO
			if Time.get_ticks_msec() - state_start_ms >= recover_ms:
				music_state = MusicState.CHASE
			return


func _start_retreat(retreat_dir: Vector2) -> void:
	music_state = MusicState.RETREAT
	SHOOT_dir = retreat_dir
	state_start_ms = Time.get_ticks_msec()


func _start_windup(dir_to_player: Vector2) -> void:
	state = State.PREP_ATTACK
	music_state = MusicState.WINDUP
	SHOOT_dir = dir_to_player
	state_start_ms = Time.get_ticks_msec()

	# start cooldown so it can't spam
	time_since_last_hit = Time.get_ticks_msec()
	time_since_prep_hit = Time.get_ticks_msec()



func _start_SHOOT() -> void:
	SoundPlayer.play(SoundManager.Sound.ZOOM)
	state = State.ATTACK
	music_state = MusicState.SHOOT
	state_start_ms = Time.get_ticks_msec()



func _start_recover() -> void:
	music_state = MusicState.RECOVER
	state_start_ms = Time.get_ticks_msec()
	velocity = Vector2.ZERO
