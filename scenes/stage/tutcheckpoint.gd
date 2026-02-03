class_name tutcheckpoint #only exists to spawn enemies in the tutorial
extends Checkpoint




func Activate(): 
	is_activated = true

func _process(_delta: float) -> void:
	if is_activated and can_spawn_enemies():
		active_enemy_counter += 1
		var enemy : EnemyData = enemy_data.front()
		EntityManager.spawn_enemy.emit(enemy)
