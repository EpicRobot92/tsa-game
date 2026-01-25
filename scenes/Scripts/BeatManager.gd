extends Node

# Fires when we enter a new beat (0, 1, 2, ...)
signal beat(beat_index: int)


signal song_started
signal song_stopped

# === TUNING ===
@export var bpm: float = 118.0
@export var hit_window_sec: float = 0.09
@export var input_offset_sec: float = 0.0

# If true, restart immediately after the master track ends kool right
@export var loop_songs: bool = true

# === SONGS ===
# We support multiple AudioStreamPlayers playing together.
# Beat timing is based on the MASTER player (index 0 by default).
var players: Array[AudioStreamPlayer] = []
var master: AudioStreamPlayer = null

# === INTERNAL STATE ===
var sec_per_beat: float = 0.5
var song_start_time_sec: float = 0.0
var last_beat_index: int = -1
var running: bool = false
var paused: bool = false

enum BeatGrade { PERFECT, GOOD, OKAY, BAD }

@export var perfect_window_sec: float = 0.09
@export var good_window_sec: float = 0.15
@export var okay_window_sec: float = 0.21






func _ready() -> void:
	_update_timing()


func _process(_delta: float) -> void:
	# Only emit beats while running and master is playing
	if not running or master == null or not master.playing:
		return

	var pos: float = get_song_position_sec()
	if pos < 0.0:
		return

	# Which beat are we currently inside?
	var current_beat_index: int = int(floor(pos / sec_per_beat))

	# Emit only when we enter a new beat
	if current_beat_index != last_beat_index:
		last_beat_index = current_beat_index
		emit_signal("beat", current_beat_index)
		#print("beat")






func set_music_players(new_players: Array[AudioStreamPlayer], master_index: int = 0) -> void:
	_disconnect_master_finished()

	players = new_players

	if players.size() == 0:
		master = null
		return

	master_index = clamp(master_index, 0, players.size() - 1)
	master = players[master_index]

	_connect_master_finished()


# Add a single player 
func add_music_player(p: AudioStreamPlayer, make_master: bool = false) -> void:
	if p == null:
		return

	_disconnect_master_finished()
	players.append(p)

	if master == null or make_master:
		master = p

	_connect_master_finished()


# Start all songs together
func start_songs() -> void:
	_update_timing()

	if master == null:
		push_warning("BeatManager: No master AudioStreamPlayer set. Call set_music_players() first.")
		return

	# Start everything in the same frame
	for p in players:
		if p != null:
			p.play()

	# Mark song "start" time (aligned to audio output)
	song_start_time_sec = _now_song_clock_sec()

	last_beat_index = -1
	running = true
	emit_signal("song_started")


# Stop beat emission; optionally stop audio too
func stop_songs(stop_audio: bool = true) -> void:
	running = false
	last_beat_index = -1

	if stop_audio:
		for p in players:
			if p != null:
				p.stop()

	emit_signal("song_stopped")



func pause_songs() -> void:
	if not running or paused:
		return

	paused = true

	# Pause all audio
	for p in players:
		if p != null and p.playing:
			p.stream_paused = true

	emit_signal("song_paused")



func resume_songs() -> void:
	if not running or not paused:
		return

	paused = false

	# Resume all audio
	for p in players:
		if p != null:
			p.stream_paused = false

	# Prevent an instant "double beat" by syncing last_beat_index
	var pos: float = get_song_position_sec()
	last_beat_index = int(floor(pos / sec_per_beat))

	emit_signal("song_resumed")

# Change BPM at runtime if needed
func set_bpm(new_bpm: float) -> void:
	bpm = max(new_bpm, 1.0)
	_update_timing()


# Current position in song (seconds since start)
func get_song_position_sec() -> float:
	if master == null:
		return 0.0

	# This is the actual playback time of the audio stream
	return float(master.get_playback_position()) + input_offset_sec


# we are using this on attack input
# Returns a Dictionary we can also use delta + beat_index for streak logic.
## Mann rhythm games are hard to code ;-;
func get_beat_result() -> Dictionary:
	var pos: float = get_song_position_sec()
	if pos < 0.0:
		return {
			"on_beat": false,
			"delta": INF,
			"beat_index": -1,
			"grade": BeatGrade.BAD
		}

	# Find nearest beat index
	var beat_float: float = pos / sec_per_beat
	var nearest_beat: int = int(round(beat_float))
	var nearest_beat_time: float = float(nearest_beat) * sec_per_beat

	# How far off from the nearest beat
	var delta: float = abs(pos - nearest_beat_time)

	# Grade it
	var grade: int = BeatGrade.BAD
	if delta <= perfect_window_sec:
		grade = BeatGrade.PERFECT
	elif delta <= good_window_sec:
		grade = BeatGrade.GOOD
	elif delta <= okay_window_sec:
		grade = BeatGrade.OKAY
	else:
		grade = BeatGrade.BAD
	print(delta)
	var on_beat: bool = grade != BeatGrade.BAD

	return {
		"on_beat": on_beat,
		"delta": delta,
		"beat_index": nearest_beat,
		"grade": grade
	}



# =========================
# LOOPING
# =========================

func _connect_master_finished() -> void:
	if master != null and not master.finished.is_connected(_on_master_finished):
		master.finished.connect(_on_master_finished)


func _disconnect_master_finished() -> void:
	if master != null and master.finished.is_connected(_on_master_finished):
		master.finished.disconnect(_on_master_finished)


func _on_master_finished() -> void:
	# If master ends, either loop all or fully stop.
	if loop_songs:
		start_songs() # restarts immediately
	else:
		stop_songs(false) # stop beat emission but don’t force-stop audio 


# TIMING HELPER functions


func _update_timing() -> void:
	sec_per_beat = 60.0 / max(bpm, 1.0)


# Audio-aligned clock (closer to what player hears)
func _now_song_clock_sec() -> float:
	var t: float = Time.get_ticks_usec() / 1_000_000.0
	var mix_offset: float = AudioServer.get_time_since_last_mix()
	var output_latency: float = AudioServer.get_output_latency()
	return t - output_latency - mix_offset
