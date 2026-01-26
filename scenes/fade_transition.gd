class_name fade_transition
extends ColorRect

@onready var fade_transition_ui: CanvasLayer = $"../.."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var fade_time := 1.0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func idle() -> void: 
	fade_transition_ui.visible = false

func fade_in() -> void: 
	show()
	fade_transition_ui.visible = true
	animation_player.play("Fade_in")

	
	
func fade_out() -> void: 
	show()
	fade_transition_ui.visible = true
	animation_player.play("Fade_out")
	
	
