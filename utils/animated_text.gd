class_name animated_text
extends RichTextLabel

signal text_finished

@export var text_list : Array[String] = []
@export var init_hide = true

@export var speed_multiplier := 1.0

const BASE_CHARACTER_DELAY := 0.035
const BASE_COMMA_DELAY := 0.18
const BASE_PERIOD_DELAY := 0.35

var is_typing := false
var typing_id := 0


func _ready() -> void:
	if init_hide == true: 
		hide()
	else:
		show()


func hide_text():
	hide()


func change_text(index):
	if index < 0 or index >= text_list.size():
		return
	
	show()
	text = text_list[index]
	type_write()


func type_write():
	typing_id += 1
	var my_typing_id = typing_id
	
	is_typing = true
	visible_characters = 0
	
	var total_characters = get_total_character_count()
	
	for i in range(total_characters):
		if my_typing_id != typing_id:
			return
		
		visible_characters = i + 1
		
		var current_character = text[i]
		var delay = BASE_CHARACTER_DELAY
		
		match current_character:
			",":
				delay = BASE_COMMA_DELAY
			".", "!", "?":
				delay = BASE_PERIOD_DELAY
		
		await get_tree().create_timer(delay * speed_multiplier).timeout
	
	is_typing = false
	text_finished.emit()
