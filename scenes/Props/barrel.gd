extends StaticBody2D

@onready var damage_receiver: Area2D = $DamageReceiver
@onready var sprite: Sprite2D = $Sprite2D

@export var knockback_intensity : float

const GRAVITY := 600.0

enum State {IDLE, DESTROYED}

var height := 0.0
var height_speed := 0.0
var state := State.IDLE
var velocity := Vector2.ZERO

func _ready() -> void:
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	
func _process(delta: float) -> void:
	position += velocity * delta
	sprite.position = Vector2.UP * height
	handle_air_time(delta)
	
func on_receive_damage(_damage: int, direction: Vector2, _hit_type: DamageReciever.HitType, _knockback_intensity) -> void: 
	if state == State.IDLE:
		state = State.DESTROYED
		sprite.frame = 1
		height_speed = knockback_intensity * 2
		velocity = direction * knockback_intensity

func handle_air_time(delta : float):
	if state == State.DESTROYED:
		modulate.a -= delta
		height += height_speed * delta
		if height < 0: 
			height = 0 
			queue_free()
		else: 
			height_speed -= GRAVITY * delta
		
	
	
