class_name fade_transition
extends ColorRect

@onready var fade_transition_ui: CanvasLayer = $"../.."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var fade_time := 1.0

@onready var timer: Timer = $Timer

var disable_vis = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func idle() -> void: 
	fade_transition_ui.visible = false
	

func fade_in(disable) -> void: 
	disable_vis = disable or disable_vis
	show()
	fade_transition_ui.visible = true
	timer.start()
	animation_player.play("Fade_in")
	

	
	
func fade_out(disable) -> void: 
	disable_vis = disable or disable_vis
	show()
	fade_transition_ui.visible = true
	timer.start()
	animation_player.play("Fade_out")
	
	

func _on_timer_timeout() -> void:
	if disable_vis:
		fade_transition_ui.visible = false
