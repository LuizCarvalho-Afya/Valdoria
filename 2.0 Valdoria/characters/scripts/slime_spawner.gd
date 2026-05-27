extends Node2D
class_name SlimeSpawner

@export var slime_scene: PackedScene = preload("res://characters/scenes/slime.tscn")
@export var respawn_time: float = 5.0
@export var spawn_on_ready: bool = true

var _current_slime: Node = null
var _waiting_respawn: bool = false


func _ready() -> void:
	if spawn_on_ready:
		_spawn_slime()


func _spawn_slime() -> void:
	if slime_scene == null or _current_slime != null:
		return

	var slime := slime_scene.instantiate()
	get_parent().call_deferred("add_child", slime)
	_current_slime = slime

	await slime.ready
	if slime is Node2D:
		(slime as Node2D).global_position = global_position

	if slime.has_method("set_spawn_position"):
		slime.call("set_spawn_position", global_position)

	# Quando usar o SlimeSpawner, o próprio spawner controla o respawn
	# para não nascerem dois slimes no mesmo lugar.
	if slime.has_method("set_respawn_enabled"):
		slime.call("set_respawn_enabled", false)

	slime.tree_exited.connect(_on_slime_tree_exited)


func _on_slime_tree_exited() -> void:
	_current_slime = null

	if _waiting_respawn:
		return

	_waiting_respawn = true
	await get_tree().create_timer(respawn_time).timeout
	_waiting_respawn = false
	_spawn_slime()
