class_name Level, "res://assets/backgrounds/level_2.png"
extends Node
signal get_new_player
signal wait_new_player(time)

#### Variables Export
export var debuggeable := false
export var debug_panel: PackedScene
export var scroll_speed := 200.0
export var send_waves := true
export var send_player_ship := true
export var time_to_start_waves := 3.0
export var time_to_spawn_player := 2.5

#### Variables Onready
onready var parallax_bg := $BackGrounds/ParallaxBackground
onready var parallax_border := $BackGrounds/ParallaxBorder
onready var parallax_decor := $BackGrounds/ParallaxDecor
onready var hud_layer := $HUD
onready var player_timer: Timer

#### Variables
var player_ships := {
	"interceptor": preload("res://game/player/PlayerInterceptor.tscn"),
	"bomber": preload("res://game/player/PlayerBomber.tscn"),
	"stealth": preload("res://game/player/PlayerStealth.tscn")
}
var ship_order := [player_ships.interceptor, player_ships.bomber, player_ships.stealth]
var current_ship_index := 0

#### Metodos
func _ready() -> void:
	if send_player_ship:
		#create_player()
		create_player_timer()
		player_timer.start()
	
	GlobalMusic.play_music(GlobalMusic.musics.level_one)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	create_timer()
	if debuggeable:
		hud_layer.add_child(debug_panel.instance())

func create_player_timer() -> void:
	player_timer = Timer.new()
	player_timer.name = "player_timer"
	player_timer.connect("timeout", self, "_on_player_timer_timeout")
	player_timer.one_shot = true
	player_timer.autostart = false
	player_timer.wait_time = time_to_spawn_player
	add_child(player_timer)

func player_destroyed() -> void:
	emit_signal("wait_new_player", time_to_spawn_player)
	current_ship_index += 1
	if current_ship_index >= ship_order.size():
		get_tree().reload_current_scene()
		#aca se termina todo
	else:
		player_timer.start()
		#create_player()

func _on_player_timer_timeout() -> void:
	create_player()

func create_player() -> void:
	var new_player:Player = ship_order[current_ship_index].instance()
# warning-ignore:return_value_discarded
	new_player.connect("destroy", self, "player_destroyed")
	add_child(new_player)
	emit_signal("get_new_player")


func create_timer() -> void:
	var send_waves_timer := Timer.new()
	send_waves_timer.one_shot = true
	send_waves_timer.wait_time = time_to_start_waves
	send_waves_timer.connect("timeout", self, "_on_send_waves_timer_timeout")
	add_child(send_waves_timer)
	send_waves_timer.start()

func _on_send_waves_timer_timeout() -> void:
	for child in get_children():
		if child.is_in_group("waves_level"):
			child.set_send_waves(send_waves)
			child.start_waves()

func _process(delta: float):
	parallax_bg.scroll_offset += Vector2.DOWN * scroll_speed * delta
	parallax_border.scroll_offset += Vector2.DOWN * scroll_speed * delta
	parallax_decor.scroll_offset += Vector2.DOWN * scroll_speed * delta * 0.5

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

