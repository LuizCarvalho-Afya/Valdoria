extends CharacterBody2D
class_name Character

signal health_changed(current_health: int, max_health: int)

var _state_machine
var _is_dead: bool = false
var _is_attacking: bool = false
var _is_invincible: bool = false
var _spawn_position: Vector2 = Vector2.ZERO
var _last_direction: Vector2 = Vector2.DOWN


@export_category("Variables")
@export var _move_speed: float = 64.0
@export var _friction: float = 0.2
@export var _acceleration: float = 0.2
@export var max_health: int = 100
@export var invincibility_time: float = 0.45
@export var respawn_time: float = 1.5
@export var respawn_invincibility_time: float = 1.0

@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _animation_tree: AnimationTree = null

# UI do inventário (AGORA AUTOMÁTICO VIA GRUPO)
@onready var _texture: Sprite2D = $Texture
@onready var _health_bar: ProgressBar = get_node_or_null("HealthBar") as ProgressBar
@onready var _health_text: Label = get_node_or_null("HealthBar/HealthText") as Label
@onready var _attack_collision: CollisionShape2D = get_node_or_null("AttackArea/Collision") as CollisionShape2D

var current_health: int = 100


func _ready() -> void:
	add_to_group("character")
	add_to_group("player")

	_spawn_position = global_position
	current_health = max_health

	if _animation_tree:
		_animation_tree.active = true
		_state_machine = _animation_tree["parameters/playback"]
		_set_animation_direction(_last_direction)

	_update_health_bar()


# 🟢 INVENTÁRIO
# O personagem não armazena mais os itens em uma lista separada.
# Ele apenas encaminha a coleta para o componente Inventario,
# onde a HashMap/Dictionary principal fica centralizada.
func add_item(item_id: String, nome_item: String = "", textura: Texture2D = null, quantidade: int = 1) -> void:
	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("adicionar_item"):
		inventario_ui.adicionar_item(item_id, nome_item, textura, quantidade)
	else:
		print("INVENTÁRIO NÃO ENCONTRADO. Coloque o nó Inventario no grupo 'inventario'.")


# Funções de apoio para consultar/remover pelo personagem, se necessário.
func consultar_item_por_id(item_id: String) -> Dictionary:
	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("consultar_por_id"):
		return inventario_ui.consultar_por_id(item_id)

	return {}


func consultar_item_por_nome(nome_item: String) -> Dictionary:
	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("consultar_por_nome"):
		return inventario_ui.consultar_por_nome(nome_item)

	return {}


func remover_item(item_id: String, quantidade: int = 1) -> bool:
	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("remover_item"):
		return inventario_ui.remover_item(item_id, quantidade)

	return false


func remover_item_completo(item_id: String) -> bool:
	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("remover_item_completo"):
		return inventario_ui.remover_item_completo(item_id)

	return false


func exibir_inventario() -> void:
	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("exibir_inventario"):
		inventario_ui.exibir_inventario()


func _physics_process(_delta: float) -> void:
	if _is_dead:
		return

	if _is_attacking:
		velocity = Vector2.ZERO
		_animate()
		move_and_slide()
		return

	_move()
	_attack()
	_animate()
	move_and_slide()


func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if _direction != Vector2.ZERO:
		# O personagem ainda anda na diagonal, mas a animação fica presa
		# em uma direção principal. Isso evita misturar frames no AnimationTree.
		_set_animation_direction(_get_cardinal_direction(_direction))

		var move_direction: Vector2 = _direction.normalized()
		velocity.x = lerp(velocity.x, move_direction.x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, move_direction.y * _move_speed, _acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, _friction)
		velocity.y = lerp(velocity.y, 0.0, _friction)


func _get_cardinal_direction(direction: Vector2) -> Vector2:
	if direction == Vector2.ZERO:
		return _last_direction

	if abs(direction.x) > abs(direction.y):
		return Vector2(1 if direction.x > 0.0 else -1, 0)

	if abs(direction.y) > abs(direction.x):
		return Vector2(0, 1 if direction.y > 0.0 else -1)

	# Quando está exatamente na diagonal pelo teclado, mantém o último eixo
	# usado para a animação não ficar trocando entre horizontal e vertical.
	if _last_direction.x != 0.0:
		return Vector2(1 if _last_direction.x > 0.0 else -1, 0)

	if _last_direction.y != 0.0:
		return Vector2(0, 1 if _last_direction.y > 0.0 else -1)

	return Vector2.DOWN


func _set_animation_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	_last_direction = direction

	if _animation_tree == null:
		return

	_animation_tree["parameters/idle/blend_position"] = direction
	_animation_tree["parameters/walk/blend_position"] = direction
	_animation_tree["parameters/attack/blend_position"] = direction
	_animation_tree["parameters/death/blend_position"] = direction


func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		if _attack_timer:
			_attack_timer.start()

		velocity = Vector2.ZERO
		_is_attacking = true


func _animate() -> void:
	if _state_machine == null:
		return

	if _is_dead:
		_state_machine.travel("death")
		return

	if _is_attacking:
		_state_machine.travel("attack")
		return

	if velocity.length() > 10:
		_state_machine.travel("walk")
		return

	_state_machine.travel("idle")


func take_damage(damage: int = 10, attacker_position: Vector2 = Vector2.ZERO) -> void:
	if _is_dead or _is_invincible:
		return

	current_health = max(current_health - damage, 0)
	_update_health_bar()
	_flash_damage()

	if attacker_position != Vector2.ZERO:
		var knockback_dir := attacker_position.direction_to(global_position)
		velocity += knockback_dir * 85.0

	if current_health <= 0:
		die()
		return

	_start_invincibility()


func heal(amount: int = 10) -> void:
	if _is_dead:
		return

	current_health = min(current_health + amount, max_health)
	_update_health_bar()


func _update_health_bar() -> void:
	if _health_bar:
		_health_bar.max_value = max_health
		_health_bar.value = current_health
		_health_bar.visible = true

	if _health_text:
		_health_text.text = str(current_health) + "/" + str(max_health)

	health_changed.emit(current_health, max_health)


func _flash_damage() -> void:
	if _texture == null:
		return

	_texture.modulate = Color(1, 0.35, 0.35, 1)
	var tween := create_tween()
	tween.tween_property(_texture, "modulate", Color(1, 1, 1, 1), 0.18)


func _flash_respawn() -> void:
	if _texture == null:
		return

	_texture.modulate = Color(0.7, 1, 0.7, 0.65)
	var tween := create_tween()
	tween.tween_property(_texture, "modulate", Color(1, 1, 1, 1), 0.35)


func _start_invincibility() -> void:
	_is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout

	if not _is_dead:
		_is_invincible = false


func _on_attack_timer_timeout() -> void:
	_is_attacking = false

	if _attack_collision:
		_attack_collision.set_deferred("disabled", true)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("update_health"):
		body.update_health()


func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	_is_attacking = false
	_is_invincible = true
	velocity = Vector2.ZERO
	_update_health_bar()

	if _attack_timer:
		_attack_timer.stop()

	if _attack_collision:
		_attack_collision.set_deferred("disabled", true)

	if _state_machine:
		_state_machine.travel("death")

	await get_tree().create_timer(respawn_time).timeout
	_respawn()


func _respawn() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
	current_health = max_health
	_is_dead = false
	_is_attacking = false
	_is_invincible = true

	_update_health_bar()
	_set_animation_direction(Vector2.DOWN)

	if _state_machine:
		_state_machine.travel("idle")

	_flash_respawn()

	await get_tree().create_timer(respawn_invincibility_time).timeout
	_is_invincible = false
