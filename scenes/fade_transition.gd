class_name fade_transition
extends ColorRect

@onready var fade_timer: Timer = $fade_timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var fade_time := 1.0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_in() -> void: 
	show()
	animation_player.play("Fade_in")
	
	
func fade_out() -> void: 
	show()
	animation_player.play("Fade_out")
	
	
