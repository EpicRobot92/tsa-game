extends Control

@export var level_1_path: String = "res://scenes/world.tscn"
@export var wait_after_text := 1.2
@export var fade_time := 0.45
@export var final_fade_time := 6.0
@export var skip_fade_time := 0.6

@onready var background: TextureRect = $Background
@onready var dialogue_text: animated_text = $TextLabel
@onready var fade_rect: ColorRect = $FadeRect


var slides := [
	{
		"image": preload("res://assets/art/Intro/Scene1.png"),
		"text_indexes": [0, 1]
	},
	{
		"image": preload("res://assets/art/Intro/Scene2.png"),
		"text_indexes": [2, 3, 4]
	},
	{
		"image": preload("res://assets/art/Intro/Scene3.png"),
		"text_indexes": [5, 6, 7, 8, 9]
	},
	{
		"image": preload("res://assets/art/Intro/Scene4.png"),
		"text_indexes": [10, 11, 12]
	},
	{
		"image": preload("res://assets/art/Intro/Scene5.png"),
		"text_indexes": [13, 14, 15, 16, 17, 18]
	},
	{
		"image": preload("res://assets/art/Intro/Scene6.png"),
		"text_indexes": [19]
	}
]

var current_slide_index := 0
var current_text_index := 0
var current_slide_texts: Array = []

var intro_running := false
var skip_requested := false


func _ready() -> void:
	intro_running = true
	
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 1.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	set_slide(0)
	run_intro()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SkipIntro"):
		skip_intro()


func skip_intro() -> void:
	if not intro_running:
		return
	
	skip_requested = true
	start_game(skip_fade_time)


func run_intro() -> void:
	await fade_from_black()

	while current_slide_index < slides.size():
		if skip_requested:
			return
		
		current_text_index = 0

		while current_text_index < current_slide_texts.size():
			if skip_requested:
				return

			var text_id = current_slide_texts[current_text_index]
			dialogue_text.change_text(text_id)

			await dialogue_text.text_finished

			if skip_requested:
				return

			await get_tree().create_timer(wait_after_text).timeout

			if skip_requested:
				return

			current_text_index += 1

		current_slide_index += 1

		if current_slide_index < slides.size():
			await transition_to_slide(current_slide_index)

	start_game(final_fade_time)


func set_slide(slide_index: int) -> void:
	var slide = slides[slide_index]
	background.texture = slide["image"]
	current_slide_texts = slide["text_indexes"]


func transition_to_slide(slide_index: int) -> void:
	dialogue_text.hide_text()

	await fade_to_black()

	set_slide(slide_index)

	await get_tree().process_frame

	await fade_from_black()


func fade_to_black(custom_fade_time := -1.0) -> void:
	var actual_fade_time = fade_time
	
	if custom_fade_time > 0.0:
		actual_fade_time = custom_fade_time
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, actual_fade_time)
	await tween.finished


func fade_from_black(custom_fade_time := -1.0) -> void:
	var actual_fade_time = fade_time
	
	if custom_fade_time > 0.0:
		actual_fade_time = custom_fade_time
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, actual_fade_time)
	await tween.finished


func start_game(fade_duration := -1.0) -> void:
	if not intro_running:
		return

	intro_running = false
	dialogue_text.hide_text()

	if fade_duration <= 0.0:
		fade_duration = final_fade_time

	await fade_to_black(fade_duration)
	get_tree().change_scene_to_file(level_1_path)
