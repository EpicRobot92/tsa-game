class_name BasicEnemy
extends Character

@export var duration_between_hits : int
@export var duration_prep_hit : int
@export var player :Player


var player_slot : EnemySlot = null
var time_since_last_hit := Time.get_ticks_msec()
var time_since_prep_hit := Time.get_ticks_msec()
var death_emitted := false


func _ready() -> void:
	super._ready()
	anim_attacks = ["punch"]

func handle_input():
	

	if player != null and can_move(): 
		
		if player_slot == null: 
			player_slot = player.reserve_slot(self)
		
		if player_slot !=null: 
			var direction := (player_slot.global_position - global_position).normalized()
			if is_player_within_range():
				velocity = Vector2.ZERO
				if can_attack() and player.current_health > 0: 
					state = State.PREP_ATTACK
					time_since_last_hit = Time.get_ticks_msec()
					time_since_prep_hit = Time.get_ticks_msec()
			else: 
				velocity = direction * speed
				
func handle_prep_attack() -> void: 
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - time_since_prep_hit > duration_between_hits): 
		state = State.ATTACK
		anim_attacks.shuffle()
	
func handle_grounded() -> void: 
	if state == State.GROUNDED and (Time.get_ticks_msec() - time_since_grounded > duration_grounded):
		if current_health == 0: 
			state = State.DEATH
		else: 
			state = State.LAND
			player.free_slot(self)
			player_slot = null

func is_player_within_range() -> bool: 
	return (player_slot.global_position - global_position).length() < 1


func can_attack():
	if Time.get_ticks_msec() - time_since_last_hit < duration_between_hits:
		return false
	return super.can_attack()
	
	

func set_heading() -> void: ## Enemy always Faces the Player
	if player == null:
		return
	if position.x > player.position.x: 
		heading = Vector2.LEFT
	else: 
		heading = Vector2.RIGHT

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReciever.HitType, knockback: float) -> void:
	super.on_receive_damage(amount, direction, hit_type, knockback)
	if current_health == 0 and not death_emitted: 
		death_emitted = true
		player.free_slot(self)
		EntityManager.death_enemy.emit(self)
		damage_receiver.monitoring = false
		
