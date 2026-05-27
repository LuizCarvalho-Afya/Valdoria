extends Area2D

# ID é a chave única usada na HashMap do inventário.
@export var item_id: String = "slime_gel"

# Nome é apenas a forma exibida para o usuário/professor.
@export var item_name: String = "Gel de Slime"

@export var item_texture: Texture2D = preload("res://characters/assets/slime_gel.png")
@export var quantidade: int = 1

# Usado quando o item é descartado do inventário para não ser coletado
# instantaneamente no mesmo frame em que nasce no chão.
@export var pickup_delay: float = 0.0


func _ready() -> void:
	add_to_group("item")

	if item_name.is_empty():
		item_name = _nome_amigavel(item_id)

	if has_node("Sprite2D"):
		$Sprite2D.texture = item_texture

	if pickup_delay > 0.0:
		_aplicar_delay_de_coleta()


func _aplicar_delay_de_coleta() -> void:
	monitoring = false
	await get_tree().create_timer(pickup_delay).timeout

	if is_inside_tree():
		monitoring = true


func _on_body_entered(body: Node2D) -> void:
	print("ENCOSTOU EM:", body.name)
	print("GRUPOS:", body.get_groups())

	if body.is_in_group("character"):
		print("ITEM COLETADO:", item_id, " | Nome:", item_name, " | Quantidade:", quantidade)

		# A coleta passa pelo personagem, mas o armazenamento real
		# fica centralizado no Inventario.gd usando Dictionary/HashMap.
		if body.has_method("add_item"):
			body.add_item(item_id, item_name, item_texture, quantidade)
		else:
			print("PERSONAGEM NÃO POSSUI MÉTODO add_item")

		queue_free()


# Mantém compatibilidade com slime_spawner.gd, caso essa cena seja usada depois.
func configurar(textura: Texture2D, nome: String = "slime_gel") -> void:
	item_texture = textura
	item_id = nome
	item_name = _nome_amigavel(nome)

	if has_node("Sprite2D"):
		$Sprite2D.texture = textura


func _nome_amigavel(id: String) -> String:
	match id:
		"slime_gel":
			return "Gel de Slime"
		"sword":
			return "Espada"
		_:
			return id.capitalize().replace("_", " ")
