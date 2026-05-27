extends CharacterBody2D

var _player_ref: Node2D = null
var _is_dead: bool = false
var _damage_timer: float = 0.0
var _spawn_position_locked: bool = false

@export var slime_scene: PackedScene = preload("res://characters/scenes/slime.tscn")
@export var drop_scene: PackedScene = preload("res://characters/scenes/drop_item.tscn")
@export var respawn_enabled: bool = true
@export var respawn_time: float = 5.0
@export var move_speed: float = 30.0
@export var damage: int = 10
@export var attack_distance: float = 18.0
@export var attack_cooldown: float = 0.85

@onready var _texture: Sprite2D = $Texture
@onready var _animation: AnimationPlayer = $Animation

var spawn_position: Vector2


func _ready() -> void:
	add_to_group("enemy")

	# Guarda o ponto original de nascimento. Quando um slime renasce,
	# esse valor é reaplicado para ele continuar voltando para o mesmo lugar.
	if not _spawn_position_locked:
		spawn_position = global_position
		_spawn_position_locked = true


func set_spawn_position(position: Vector2) -> void:
	spawn_position = position
	_spawn_position_locked = true


func set_respawn_enabled(enabled: bool) -> void:
	respawn_enabled = enabled


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_damage_timer = max(_damage_timer - delta, 0.0)
	velocity = Vector2.ZERO

	if _player_ref != null:
		var distance_to_player: float = global_position.distance_to(_player_ref.global_position)

		if distance_to_player > attack_distance:
			var dir: Vector2 = global_position.direction_to(_player_ref.global_position)
			velocity = dir * move_speed
			move_and_slide()
		else:
			_try_damage_player()

	_animate()


func _try_damage_player() -> void:
	if _player_ref == null or _damage_timer > 0.0:
		return

	if _player_ref.has_method("take_damage"):
		_player_ref.take_damage(damage, global_position)
		_damage_timer = attack_cooldown
		print("SLIME DEU DANO:", damage)


func _animate() -> void:
	if _texture == null or _animation == null:
		return

	if velocity.x > 0:
		_texture.flip_h = false
	elif velocity.x < 0:
		_texture.flip_h = true

	if velocity != Vector2.ZERO:
		_animation.play("walk")
	else:
		_animation.play("idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("character") or body.is_in_group("player"):
		_player_ref = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player_ref:
		_player_ref = null


func update_health() -> void:
	if _is_dead:
		return

	_is_dead = true
	velocity = Vector2.ZERO
	print("SLIME MORREU - RESPAWN EM", respawn_time, "SEGUNDOS")

	if _animation:
		_animation.play("death")

	call_deferred("_die_safe")


func _die_safe() -> void:
	var parent_node: Node = get_parent()
	var respawn_position: Vector2 = spawn_position
	var drop_position: Vector2 = global_position

	# Deixa a animação de morte aparecer antes de remover o slime.
	await get_tree().create_timer(0.35).timeout

	_drop(drop_position)

	if respawn_enabled and parent_node != null and is_instance_valid(parent_node):
		_schedule_respawn(parent_node, respawn_position)

	queue_free()


func _schedule_respawn(parent_node: Node, respawn_position: Vector2) -> void:
	# O Timer fica no pai do slime, então ele continua existindo mesmo depois
	# que o slime morto sai da cena.
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = respawn_time
	parent_node.add_child(timer)

	timer.timeout.connect(func() -> void:
		if parent_node == null or not is_instance_valid(parent_node):
			timer.queue_free()
			return

		var scene_to_spawn: PackedScene = slime_scene
		if scene_to_spawn == null:
			var loaded_scene := load("res://characters/scenes/slime.tscn")
			if loaded_scene is PackedScene:
				scene_to_spawn = loaded_scene

		if scene_to_spawn != null:
			var new_slime: Node = scene_to_spawn.instantiate()
			parent_node.add_child(new_slime)

			if new_slime is Node2D:
				(new_slime as Node2D).global_position = respawn_position

			if new_slime.has_method("set_spawn_position"):
				new_slime.call("set_spawn_position", respawn_position)

		print("SLIME RESPAWNOU")
		timer.queue_free()
	)

	timer.start()


func _drop(drop_position: Vector2) -> void:
	if drop_scene == null:
		return

	var drop = drop_scene.instantiate()
	get_parent().add_child(drop)
	drop.global_position = drop_position


# Mantém a conexão existente da cena sem gerar erro no editor.
func _on_animation_finished(_anim_name: StringName) -> void:
	pass
