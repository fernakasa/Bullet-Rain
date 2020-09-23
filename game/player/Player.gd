class_name Player
extends KinematicBody2D

#### Enumerables
enum States { INIT, IDLE, RESPAWNING, MOVING, SHOOTING, GOD, DEAD }

#### Variables Export
export var speed := 200.0
export var bullet: PackedScene
export var bullet_damage := 1.0
export(float, 0.15, 0.32) var shooting_rate := 0.2
export var hitpoints := 4
export(Color, RGBA) var colorTrail
export var is_in_god_mode := false

#### Variables
var state = States.INIT
var state_text := "INIT"
var can_shoot := true
var speed_multiplier := 0.8
var speed_using := 0.0
var speed_shooting: float
var speed_respawning := 0
var bullet_type := 1
var bullet_speed := -700

#### Variables Onready
onready var bullet_container: Node
onready var shoot_positions := $ShootPositions
onready var gun_timer := $GunTimer
onready var movement := Vector2.ZERO
onready var shoot_sound := $ShootSFX
onready var hitpoint_sound := $HitpointSFX
onready var explosion_sound := $ExplosionSFX
onready var animation_play := $AnimationPlayer


#### Setters y Getters
func set_movement(value: Vector2) -> void:
	movement = value

func get_movement() -> float:
	return movement.length()

func get_shoot_rate() -> float:
	return gun_timer.wait_time

func get_state() -> String:
	return state_text


#### Metodos
func _ready() -> void:
	change_state(States.IDLE)
	speed_shooting = speed * speed_multiplier
	gun_timer.wait_time = shooting_rate
	speed_using = speed
	bullet_container = check_bullet_container()


func _physics_process(_delta) -> void:
	movement = speed_using * get_direction().normalized()
	
# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector2.ZERO)


func _process(_delta) -> void:
	shoot_input()


func get_direction() -> Vector2:
	var direction := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if not state in [States.SHOOTING, States.DEAD, States.RESPAWNING]:
		if direction.length() > 0:
			change_state(States.MOVING)
		else:
			change_state(States.IDLE)
	
	return direction

func check_bullet_container() -> Node:
	if owner != null:
		if owner.get_node("BulletsContainer") != null:
			return owner.get_node("BulletsContainer")
		else:
			return owner
	else:
		return self


func shoot_input() -> void:
	if Input.is_action_just_pressed("ui_change_bullet"):
		bullet_type *= -1
	
	if Input.is_action_pressed("ui_shoot"):
		change_state(States.SHOOTING)
		if can_shoot:
			shoot()
			gun_timer.start()
			can_shoot = false

	if Input.is_action_just_released("ui_shoot"):
		change_state(States.IDLE)


func shoot() -> void:
	shoot_sound.play()
	for i in range(shoot_positions.get_child_count()):
		var new_bullet := bullet.instance()
		new_bullet.create(
				shoot_positions.get_child(i).global_position,
				bullet_speed,
				0.0,
				bullet_type,
				bullet_damage)
		bullet_container.add_child(new_bullet)


func _on_GunTimer_timeout() -> void:
	can_shoot = true

func take_damage() -> void:
	if not is_in_god_mode:
		hitpoints -= 1
		hitpoint_sound.play()
		if hitpoints == 0:
			animation_play.stop()
			animation_play.play("destroy")
		else:
			animation_play.play("damage")

func disabled_collider() -> void:
	$DamageCollider.set_deferred("disabled", true)

func play_explosion_sfx() -> void:
	explosion_sound.play()

func change_state(new_state) -> void:
	match new_state:
		States.IDLE:
			speed_using = speed
			state_text = "IDLE"
		States.MOVING:
			speed_using = speed
			state_text = "MOVING"
		States.RESPAWNING:
			speed_using = speed_respawning
			state_text = "RESPAWNING"
		States.SHOOTING:
			speed_using = speed_shooting
			state_text = "SHOOTING"
		States.GOD:
			is_in_god_mode = true
			state_text = "GOD"
		States.DEAD:
			speed_using = speed_respawning
			state_text = "DEAD"
	state = new_state
