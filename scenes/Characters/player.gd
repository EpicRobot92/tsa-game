class_name Player
extends Character

@onready var enemy_slots: Array = $EnemySlots.get_children()

enum Twin { ECLIPTIO, NOVA }

@onready var ecliptio_visual: Node2D = $EcliptioVisual
@onready var nova_visual = $NovaVisual
@export var swap_cooldown := 500

var current_twin := Twin.ECLIPTIO
var active_visual: Node2D

var time_since_swapped = Time.get_ticks_msec()






func _ready() -> void:
	super._ready()
	anim_attacks = ["punch", "punch_alt", "kick", "roundkick"]
	## sets up the current twin
	set_active_visual(
		nova_visual if current_twin == Twin.NOVA else ecliptio_visual
	)
	
## Makes the current twin visible
func set_active_visual(v: Node2D) -> void:
	if active_visual:
		active_visual.visible = false

	active_visual = v
	active_visual.visible = true

	animation_player = active_visual.get_node("AnimationPlayer")
	character_sprite = active_visual.get_node("CharacterSprite")
	
## swaps the twin and plays the current state
func swap_twin():
	current_twin = Twin.NOVA if current_twin == Twin.ECLIPTIO else Twin.ECLIPTIO
	set_active_visual(
		nova_visual if current_twin == Twin.NOVA else ecliptio_visual
	)
	animation_player.play(anim_map[state])
## checks if the player can swap by getting the time in-tween last swap and checks if more or equal time has passed since the cooldown and if the state is idle
func can_swap() -> bool:
	return true if (Time.get_ticks_msec() - time_since_swapped >= swap_cooldown) and [State.IDLE].has(state) else false



func handle_input() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed

	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
		if is_last_hit_successful:
			attack_combo_index = (attack_combo_index + 1) % anim_attacks.size() # rotates the attack Anims
			is_last_hit_successful = false
		else: 
			attack_combo_index = 0
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF

	if can_jumpkick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
	if can_swap() and Input.is_action_just_pressed("swap"): 
		swap_twin()
		time_since_swapped = Time.get_ticks_msec()
	
		
func set_heading() -> void: 
	if velocity.x > 0: 
		heading = Vector2.RIGHT
	elif velocity.x < 0: 
		heading = Vector2.LEFT

func reserve_slot(enemy: BasicEnemy) -> EnemySlot: 
	var availiable_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if availiable_slots.size() == 0:
		return null
	availiable_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	availiable_slots[0].occupy(enemy)
	return availiable_slots[0]

func free_slot(enemy : BasicEnemy) -> void: 
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	if target_slots.size() == 1: 
		target_slots[0].free_up()
	
