class_name ShootPosition
extends Position2D

#### Variables Export
export var bullet_angle := 0.0
export var bullet_quantity := 1
export var angle_separation := 0.0

#### Variables
var bullet_container: Node
var parent: Object
var bullet: PackedScene
var can_shoot := true setget set_can_shoot, get_can_shoot

#### Variables Onready
onready var bullet_type := -1

#### Setters y Getters
func get_bullet_angle () -> float:
	return bullet_angle

func get_bullet_type() -> int:
	return bullet_type

func set_can_shoot(value: bool) -> void:
	can_shoot = value

func get_can_shoot() -> bool:
	return can_shoot

#### Metodos
func _ready() -> void:
	add_to_group("shoot_position")
	if owner != null:
		parent = owner
		bullet = parent.get_bullet()
	
	bullet_container = get_tree().get_nodes_in_group("bullets_container")[0]


func shoot_bullet(speed: float, dir: float, type: int, damage: float, angle_correction := 0.0, debug := false) -> void:
	if not can_shoot:
		return
	var ang_sep := -angle_separation
	for _i in range(bullet_quantity):
		var new_bullet:Bullet = bullet.instance()
		new_bullet.create(
			parent,
			global_position,
			speed,
			dir,
			type,
			damage,
			bullet_angle + angle_correction + ang_sep
		)
		
		ang_sep += angle_separation
		bullet_container.add_child(new_bullet)
	
	if debug:
		print(
			"Creador: {c} - Vel: {s} - Daño: {d}".format({
				"c": owner, "s": speed, "d": damage
			})
		)

