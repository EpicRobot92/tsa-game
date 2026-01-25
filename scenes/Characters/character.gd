class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var can_respawn : bool
@export var damage : int
@export var damage_power : int
@export var duration_grounded : float 
@export var flight_speed : float
@export var jump_intensity : float
@export var knockback_intensity : float
@export var knockdown_intensity : float
@export var max_health : int
@export var type : Type
@export var speed : float
@export var knockback_resistance: float = 1.0 # 0.7 heavy, 1.3 light





@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collateral_damage_emmiter: Area2D = $CollateralDamageEmmiter
@onready var damage_emmiter: Area2D = $DamageEmmiter
@onready var damage_receiver: DamageReciever = $DamageReceiver



enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY, PREP_ATTACK}
enum Type {PLAYER, BASIC_ENEMY}

var anim_attacks := []
var anim_map : Dictionary = {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "grounded",
	State.FLY: "fly",
	State.PREP_ATTACK: "idle",
	
}
var attack_combo_index := 0
var current_health := 0
var heading := Vector2.RIGHT
var height := 0.0
var height_speed := 0.0
var is_last_hit_successful := false
var time_since_grounded := Time.get_ticks_msec()
var state = State.IDLE

func _ready() -> void:
	damage_emmiter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	collateral_damage_emmiter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emmiter.body_entered.connect(on_wall_hit.bind())
	set_health(max_health, type == Character.Type.PLAYER)
	

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	handle_prep_attack()
	handle_grounded()
	handle_death(delta)
	set_heading()
	flip_sprites()
	character_sprite.position = Vector2.UP * height
	collision_shape.disabled = is_collision_disabled()
	move_and_slide()
	
	
	

func handle_movement():
	if can_move(): 
		if velocity.length() == 0: 
			state = State.IDLE
		else: 
			state = State.WALK
	
		
func handle_input():
	pass

func handle_prep_attack() -> void: 
	pass

func handle_grounded() -> void: 
	if state == State.GROUNDED and (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
		if current_health == 0: 
			state = State.DEATH
		else: 
			state = State.LAND

func handle_death(delta : float) -> void:
	if state == State.DEATH and not can_respawn: 
		modulate.a -= delta / 2.0
		if modulate.a <= 0: 
			queue_free()
	
		
func handle_animations():
	if state == State.ATTACK: 
		animation_player.play(anim_attacks[attack_combo_index])
	elif animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])
	
func handle_air_time(delta: float) -> void:
	## the fix for jump bug
	if height > 0.0 or [State.JUMP, State.JUMPKICK, State.FALL].has(state):
		height += height_speed * delta

		if height <= 0.0:
			height = 0.0

			# If we were knocked down, go grounded. orrr we land.
			if state == State.FALL:
				state = State.GROUNDED
				time_since_grounded = Time.get_ticks_msec()
			else:
				state = State.LAND

			height_speed = 0.0
			velocity = Vector2.ZERO
		else:
			height_speed -= GRAVITY * delta

			
func set_heading() -> void: 
	pass
func flip_sprites(): 
	if heading == Vector2.RIGHT: 
		character_sprite.flip_h = false
		damage_emmiter.scale.x = 1
	elif velocity.x < 0: 
		character_sprite.flip_h = true
		damage_emmiter.scale.x = -1
		
func can_move(): 
	return state == State.IDLE or state == State.WALK
		
func can_attack():
	return state == State.IDLE or state == State.WALK

func can_jump() -> bool: 
	return state == State.IDLE or state == State.WALK

func can_jumpkick() -> bool: 
	return state == State.JUMP

func can_get_hurt() -> bool: 
	return [State.IDLE, State.WALK, State.TAKEOFF, State.JUMP, State.LAND, State.PREP_ATTACK].has(state)

func is_collision_disabled() -> bool: 
	return [State.GROUNDED, State.DEATH, State.FLY].has(state)


func on_action_complete(): 
	state = State.IDLE 

func on_takeoff_complete() -> void:
	state = State.JUMP
	height_speed = jump_intensity

func on_land_complete() -> void:
	state = State.IDLE
	
func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReciever.HitType, knockback: float) -> void:
	if can_get_hurt():
		set_health(current_health - amount)

		
		var kb := knockback

		if current_health == 0 or hit_type == DamageReciever.HitType.KNOCKDOWN:
			state = State.FALL
			height_speed = knockdown_intensity
			velocity = direction * kb * knockback_resistance
		elif hit_type == DamageReciever.HitType.POWER:
			state = State.FLY
			velocity = direction * flight_speed
		else:
			state = State.HURT
			velocity = direction * kb * knockback_resistance

func on_emit_damage(receiver: DamageReciever) -> void:
	var hit_type := DamageReciever.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var current_damage := damage

	if state == State.JUMPKICK:
		hit_type = DamageReciever.HitType.KNOCKDOWN

	if attack_combo_index == anim_attacks.size() - 1:
		hit_type = DamageReciever.HitType.POWER
		current_damage = damage_power

	# character sends knockback :D
	receiver.damage_received.emit(current_damage, direction, hit_type, knockback_intensity)
	is_last_hit_successful = true

	
func on_emit_collateral_damage(receiver : DamageReciever) -> void: 
	if receiver != damage_receiver: 
		var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(0, direction, DamageReciever.HitType.KNOCKDOWN, knockback_intensity)

	

func on_wall_hit(_wall: AnimatableBody2D) -> void: 
	state = State.FALL
	height_speed = knockdown_intensity
	velocity = -velocity / 2.0
	

func set_health(health: int, emit_signal: bool = true) -> void:
	current_health = clamp(health, 0, max_health)
	if emit_signal:
		DamageManager.health_change.emit(type, current_health, max_health)
	
