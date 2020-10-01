class_name PathEndOut
extends EnemyPath

#### Metodos
func _ready() -> void:
	create_timer()

func at_end_of_path() -> String:
	return "free"

func _on_Timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if enemies_spawned < enemy_number:
		create_random_enemy()
		spawn_timer.start()
	else:
		spawn_timer.stop()
