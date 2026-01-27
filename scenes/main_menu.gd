extends Node2D
@onready var fade_trans: fade_transition = $fade_transitionUI/Control/fade_transition
@onready var fade_timer: Timer = $fade_transitionUI/fade_timer




var button_type = null

func _ready() -> void:
	fade_trans.fade_out(true)
	button_type = "init"

func _on_start_pressed() -> void:
	button_type = "start"
	
	fade_trans.fade_in(false)
	fade_timer.start()
	

func _on_tutorial_pressed() -> void:
	button_type = "tutorial"
	fade_trans.fade_in(false)
	fade_timer.start()
	


func _on_credits_pressed() -> void:
	button_type = "credits"
	

func _on_fade_timer_timeout() -> void:
	if button_type == "init":
		fade_trans.idle()
	if button_type == "start": 
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	if button_type == "tutorial": 
		pass
	if button_type == "credits": 
		pass
		
		
