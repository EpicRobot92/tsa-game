class_name Player
extends Character

@onready var enemy_slots: Array = $EnemySlots.get_children()

enum Twin { ECLIPTIO, NOVA }

@onready var ecliptio_visual: Node2D = $EcliptioVisual
@onready var nova_visual = $NovaVisual
@export var swap_cooldown := 500
@export var nova_cooldown := 200
var time_since_nova_attack : float 
@export var nova_projectile_scene: PackedScene




@export var current_twin := Twin.ECLIPTIO
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
	EntityManager.emit_signal("twin_swapped", current_twin)
	set_active_visual(
		nova_visual if current_twin == Twin.NOVA else ecliptio_visual
	)
	animation_player.play(anim_map[state])
## checks if the player can swap by getting the time in-tween last swap and checks if more or equal time has passed since the cooldown and if the state is idle
func can_swap() -> bool:
	return true if (Time.get_ticks_msec() - time_since_swapped >= swap_cooldown) and [State.IDLE, State.WALK].has(state) else false

func can_nova_attack() -> bool:
	return true if (Time.get_ticks_msec() - time_since_nova_attack >= nova_cooldown) and [State.IDLE, State.WALK].has(state) else false


## Gets a random enemy that is on the side the player is facing
func get_random_enemy_prefer_facing() -> Node2D:
	# Collectenemies from slots
	var enemies: Array[Node2D] = []
	for slot in enemy_slots:
		if slot != null and not slot.is_free() and is_instance_valid(slot.occupant):
			enemies.append(slot.occupant)

	if enemies.is_empty():
		return null

	# Split by if they are where nova is facing
	var preferred: Array[Node2D] = [] # facing
	var other: Array[Node2D] = [] # not facing

	for e in enemies:
		var dx := e.global_position.x - global_position.x
		
		var is_on_facing_side := (heading == Vector2.RIGHT and dx >= 0) or (heading == Vector2.LEFT and dx <= 0)
		if is_on_facing_side:
			preferred.append(e)
		else:
			other.append(e)

	# Pick from preferred most of the time if available
	if not preferred.is_empty():
		return preferred[randi() % preferred.size()]

	# Fallback
	if not other.is_empty():
		return other[randi() % other.size()]

	# If somehow only preferred exists
	return preferred[randi() % preferred.size()]


func fire_nova_shot(enemy: Node2D) -> void:
	var beat := BeatManager.grade_player_action()

	 #DAMAGE SCALING 
	var dmg_mult := 1.0
	match int(beat["grade"]):
		BeatManager.BeatGrade.PERFECT: dmg_mult = 2.0
		BeatManager.BeatGrade.GOOD:    dmg_mult = 1.3
		BeatManager.BeatGrade.OKAY:    dmg_mult = 1.0
		_:                             dmg_mult = 0.6

	var base_damage := 2
	var dmg := int(round(base_damage * dmg_mult))

	#SPEED SCALING
	var speed_mult := 1.0
	match int(beat["grade"]):
		BeatManager.BeatGrade.PERFECT: 
			speed_mult = 1.6
			print("Perfect")
		BeatManager.BeatGrade.GOOD:    
			speed_mult = 1.3
			print("Good")
		BeatManager.BeatGrade.OKAY:    
			speed_mult = 1.0
			print("Okay")
		_:                             
			speed_mult = 0.8
			print("Bad")

	var base_speed := 100.0
	var proj_speed := base_speed * speed_mult

	#KNOCKBACK
	var kb_mult := 1.0
	match int(beat["grade"]):
		BeatManager.BeatGrade.PERFECT: kb_mult = 1.8
		BeatManager.BeatGrade.GOOD:    kb_mult = 1.3
		BeatManager.BeatGrade.OKAY:    kb_mult = 1.0
		_:                             kb_mult = 0.6

	var base_kb := 220.0
	var kb := base_kb * kb_mult

	# Spawn projectile with configurationnnss!
	EntityManager.spawn_projectile(
		nova_projectile_scene,
		global_position,
		heading,
		enemy,
		{
			"damage": dmg,
			"speed": proj_speed,
			"knockback": kb
		}
	)





func handle_input() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if can_move():
		velocity = direction * speed

	if can_attack() and current_twin == Twin.ECLIPTIO and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
		if is_last_hit_successful:
			attack_combo_index = (attack_combo_index + 1) % anim_attacks.size() # rotates the attack Anims
			is_last_hit_successful = false
		else: 
			attack_combo_index = 0
	if can_attack() and current_twin == Twin.NOVA and can_nova_attack() and Input.is_action_just_pressed("attack"):
			var enemy := get_random_enemy_prefer_facing() 
			if enemy:
				state = State.ATTACK
				fire_nova_shot(enemy)
				time_since_nova_attack = Time.get_ticks_msec()
				

	if can_jump() and current_twin == Twin.ECLIPTIO and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF

	if can_jumpkick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
	if can_swap() and Input.is_action_just_pressed("swap"): 
		swap_twin()
		time_since_swapped = Time.get_ticks_msec()
	
# checks if the player is facing right or left
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
	
