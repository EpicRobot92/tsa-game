class_name EnemyData 
extends Resource

@export var type: Character.Type
@export var global_position : Vector2

func _init(character_type: Character.Type = Character.Type.BASIC_ENEMY, position: Vector2 = Vector2.ZERO):
	type = character_type
	global_position = position
