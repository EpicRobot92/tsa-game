class_name animated_text
extends RichTextLabel

@export var text_list : Array[String] = []

@export var init_hide = true

func _ready() -> void:
	if init_hide == true: 
		hide()
	else:
		show()
 
func hide_text():
	hide()


func change_text(index):
	show()
	text = text_list[index]
	type_write()
	

func type_write():
	   # Set the speed (seconds per full text display)
	var duration = 1
	
	# Ensure text starts invisible
	visible_ratio = 0.0
	
	# Create the tween
	var tween = create_tween()
	
	# Tween the visible_ratio from 0 to 1
	tween.tween_property(self, "visible_ratio", 1.0, duration)
