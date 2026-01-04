extends CharacterBody2D

@export var damage : int
@export var health : int
@export var speed : float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = $CharacterSprite


enum State {IDLE, WALK, ATTACK}

var state = State.IDLE


func _process(_delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	flip_sprites()
	move_and_slide()
	

func handle_movement():
	if can_move(): 
		if velocity.length() == 0: 
			state = State.IDLE
		else: 
			state = State.WALK
	else:
		velocity = Vector2.ZERO
		
func handle_input():
	## normalizies the direction then moves the character
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
		
func handle_animations():
	if state == State.IDLE: 
		animation_player.play("idle")
	elif state == State.WALK: 
		animation_player.play("walk")
	elif state == State.ATTACK: 
		animation_player.play("punch")
		
func flip_sprites(): 
	if velocity.x > 0: 
		character_sprite.flip_h = false
	elif velocity.x < 0: 
		character_sprite.flip_h = true
		
func can_move(): 
	return state == State.IDLE or state == State.WALK
		
func can_attack():
	return state == State.IDLE or state == State.WALK


func on_action_complete(): 
	state = State.IDLE 
