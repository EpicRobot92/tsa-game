extends Control

@onready var game_over: Control = $"."
@onready var fade_transition: fade_transition = $fade_transitionUI/Control/fade_transition
@onready var animation_player: AnimationPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over.visible = false
	StageManager.player_died.connect(on_died.bind())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_died() -> void: 
	animation_player.play("Died")
	game_over.visible = true
	get_tree().paused = true
	





func _on_main_menu_pressed() -> void:
	fade_transition.fade_in(false)
	await fade_transition.animation_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	


func _on_restart_pressed() -> void:
	get_tree().paused = false
	StageManager.restart_stage.emit()
	animation_player.play("next_level")
	await animation_player.animation_finished
	game_over.visible = false
	
