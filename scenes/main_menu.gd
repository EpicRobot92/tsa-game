extends Node2D
@onready var fade_trans: fade_transition = $fade_transitionUI/Control/fade_transition
@onready var fade_timer: Timer = $fade_transitionUI/fade_timer
@onready var credit: Control = $Credit


var button_type = null

var credits_open = false 


func _ready() -> void:
	get_tree().paused = false
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
	if credits_open:
		credits_open = false
		credit.visible = false
	else:
		credits_open = true
		credit.visible = true
	
	


func _on_fade_timer_timeout() -> void:
	if button_type == "init":
		fade_trans.idle()
	if button_type == "start": 
		StageManager.start_level = 0
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	if button_type == "tutorial": 
		StageManager.start_level = -1
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	if button_type == "credits": 
		pass
		
		

func handle_input(): 
	if Input.is_action_just_pressed("Pause"): 
		if credits_open == true:
			_on_credits_pressed()

func _on_exit_credits_pressed() -> void:
	_on_credits_pressed()
