class_name Projectile
extends Area2D

enum Type { DIRECTION, TARGET }

@export var projectile_type: Type = Type.DIRECTION
@export var speed: float = 650.0
@export var lifetime: float = 2.0
@export var damage: int = 1   # set per projectile scene

# Direction mode
var direction: Vector2 = Vector2.RIGHT

# Target mode
var target: Node2D = null
@export var target_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	match projectile_type:
		Type.DIRECTION:
			global_position += direction * speed * delta

		Type.TARGET:
			if is_instance_valid(target):
				var aim_pos = target.global_position + target_offset
				var new_dir = (aim_pos - global_position)
				if new_dir.length() > 0.001:
					direction = new_dir.normalized()

			# ALWAYS move forward
			global_position += direction * speed * delta

func setup_direction(dir: Vector2) -> void:
	projectile_type = Type.DIRECTION
	direction = dir.normalized()

func setup_target(t: Node2D) -> void:
	projectile_type = Type.TARGET
	target = t

func _apply_damage(node: Node) -> void:
	if node is DamageReciever:
		var recv := node as DamageReciever
		var hit_dir := Vector2.LEFT if recv.global_position.x < global_position.x else Vector2.RIGHT
		recv.damage_received.emit(damage, hit_dir, DamageReciever.HitType.NORMAL)
	elif node.has_node("DamageReceiver"):
		var recv2: DamageReciever = node.get_node("DamageReceiver")
		var hit_dir2 := Vector2.LEFT if recv2.global_position.x < global_position.x else Vector2.RIGHT
		recv2.damage_received.emit(damage, hit_dir2, DamageReciever.HitType.NORMAL)

func _on_body_entered(body: Node) -> void:
	print("hit")
	_apply_damage(body)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	print("hit")
	_apply_damage(area)
	queue_free()
