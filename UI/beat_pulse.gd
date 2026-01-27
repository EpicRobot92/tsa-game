extends ColorRect

@export var punch_scale := Vector2(1.35, 1.35)
@export var punch_in := 0.05
@export var punch_out := 0.10

@export var color_perfect := Color("#4cff4c")
@export var color_good := Color("#ffe34c")
@export var color_okay := Color("#ff9f4c")
@export var color_bad := Color("#ff4c4c")
@export var idle_color := Color.WHITE

var base_scale: Vector2
var tween: Tween

func _ready() -> void:
	# centers the beat
	pivot_offset = size * 0.5
	
	base_scale = scale
	color = idle_color

	BeatManager.beat.connect(_on_beat)
	BeatManager.player_action_graded.connect(_on_player_action_graded)

func _on_beat(_beat_index: int) -> void:
	_pulse()

func _on_player_action_graded(grade: int, _delta: float, _beat_index: int) -> void:
	apply_grade(grade)
	_pulse() 

func _pulse() -> void:
	if tween and tween.is_running():
		tween.kill()

	scale = base_scale
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base_scale * punch_scale, punch_in)
	tween.tween_property(self, "scale", base_scale, punch_out)

func apply_grade(grade: int) -> void:
	match grade:
		BeatManager.BeatGrade.PERFECT: color = color_perfect
		BeatManager.BeatGrade.GOOD: color = color_good
		BeatManager.BeatGrade.OKAY: color = color_okay
		_: color = color_bad
