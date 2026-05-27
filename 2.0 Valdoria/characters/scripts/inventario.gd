extends Control

# ============================================================
# INVENTÁRIO COM HASHMAP / DICTIONARY
# ============================================================
# Estrutura principal obrigatória da atividade:
# chave: ID único do item
# valor: outro Dictionary com nome, quantidade e textura.
#
# Exemplo:
# inventario = {
#   "slime_gel": {
#       "id": "slime_gel",
#       "nome": "Gel de Slime",
#       "quantidade": 3,
#       "textura": Texture2D
#   }
# }
#
# Observação importante:
# A HashMap acima continua sendo a estrutura principal do inventário.
# A lista ordem_slots serve apenas para guardar a posição VISUAL dos itens
# nos slots da interface, permitindo arrastar de um slot para outro.
# ============================================================

const DROP_ITEM_SCENE: PackedScene = preload("res://characters/scenes/drop_item.tscn")

var inventario: Dictionary = {}
var ordem_slots: Array = []

@onready var painel: Panel = $Panel
@onready var lista: GridContainer = $Panel/GridContainer
@onready var titulo: Label = get_node_or_null("Panel/Titulo")


func _ready() -> void:
	add_to_group("inventario")
	hide()
	_garantir_layout_slots()

	# Mensagem antiga removida. O inventário agora mostra apenas o título.
	if titulo:
		titulo.text = "INVENTÁRIO"

	# Item inicial do jogador. Ele também entra na HashMap,
	# não apenas no slot visual.
	adicionar_item(
		"sword",
		"Espada",
		preload("res://characters/assets/sword.png"),
		1
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventario"):
		visible = !visible
		if visible:
			_animar_abertura()
			exibir_inventario()


func _animar_abertura() -> void:
	if painel == null:
		return

	painel.scale = Vector2(0.92, 0.92)
	painel.modulate.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(painel, "scale", Vector2.ONE, 0.12)
	tween.tween_property(painel, "modulate:a", 1.0, 0.12)


# ============================================================
# 1) ADICIONAR ITEM
# ============================================================
# Caso o ID já exista na HashMap, apenas soma a quantidade.
# Caso não exista, cria um novo registro com ID, nome e quantidade.
func adicionar_item(item_id, nome_item: String = "", textura: Texture2D = null, quantidade: int = 1) -> bool:
	var id: String = str(item_id)
	var nome: String = nome_item
	var item_textura: Texture2D = textura
	var item_ja_existia := inventario.has(id)

	# Compatibilidade com chamadas antigas: adicionar_item(textura)
	if item_id is Texture2D:
		item_textura = item_id
		id = item_textura.resource_path
		nome = id
		item_ja_existia = inventario.has(id)

	if id.is_empty():
		print("ID DO ITEM INVÁLIDO")
		return false

	if nome.is_empty():
		nome = _nome_amigavel(id)

	if quantidade <= 0:
		print("QUANTIDADE INVÁLIDA PARA ADICIONAR:", quantidade)
		return false

	# Acesso rápido pela chave do mapa/hash.
	if inventario.has(id):
		inventario[id]["quantidade"] += quantidade
	else:
		inventario[id] = {
			"id": id,
			"nome": nome,
			"quantidade": quantidade,
			"textura": item_textura
		}

	# Se já existia sem textura e agora recebemos uma, atualiza.
	if item_textura != null:
		inventario[id]["textura"] = item_textura

	# A posição nos slots é apenas visual. O item novo vai para o primeiro slot vazio.
	if not item_ja_existia:
		_colocar_id_no_primeiro_slot_vazio(id)
	elif not _id_esta_no_layout(id):
		_colocar_id_no_primeiro_slot_vazio(id)

	print("ITEM ADICIONADO/ATUALIZADO:", inventario[id])
	_atualizar_slots_pela_hashmap()
	return true


# Mantém compatibilidade com o nome usado antes no projeto.
func add_item(item_id: String, nome_item: String = "", textura: Texture2D = null, quantidade: int = 1) -> bool:
	return adicionar_item(item_id, nome_item, textura, quantidade)


# ============================================================
# 2) CONSULTAR ITEM POR ID
# ============================================================
# Busca direta pela chave da HashMap.
func consultar_por_id(item_id: String) -> Dictionary:
	if inventario.has(item_id):
		var item: Dictionary = inventario[item_id]
		print("ITEM EXISTE | ID:", item_id, "| Nome:", item["nome"], "| Quantidade:", item["quantidade"])
		return item

	print("ITEM NÃO EXISTE | ID:", item_id)
	return {}


# ============================================================
# 3) CONSULTAR ITEM POR NOME
# ============================================================
# A estrutura principal continua sendo a HashMap por ID.
# Aqui percorremos os valores apenas para permitir a busca por nome.
func consultar_por_nome(nome_item: String) -> Dictionary:
	var nome_buscado := nome_item.to_lower()

	for id in inventario.keys():
		var item: Dictionary = inventario[id]
		var nome_atual: String = str(item["nome"]).to_lower()

		if nome_atual == nome_buscado:
			print("ITEM EXISTE | ID:", id, "| Nome:", item["nome"], "| Quantidade:", item["quantidade"])
			return item

	print("ITEM NÃO EXISTE | Nome:", nome_item)
	return {}


# ============================================================
# 4) EXIBIR INVENTÁRIO
# ============================================================
func exibir_inventario() -> void:
	print("========== INVENTÁRIO / HASHMAP ==========")

	if inventario.is_empty():
		print("Inventário vazio")
		return

	for id in inventario.keys():
		var item: Dictionary = inventario[id]
		print("ID:", id, " | Nome:", item["nome"], " | Quantidade:", item["quantidade"])

	print("HASHMAP COMPLETA:", inventario)


# ============================================================
# 5) REMOVER ITEM
# ============================================================
# Remove uma quantidade específica. Se a quantidade chegar a zero,
# o registro inteiro é apagado da HashMap.
func remover_item(item_id: String, quantidade: int = 1) -> bool:
	if not inventario.has(item_id):
		print("NÃO FOI POSSÍVEL REMOVER. ITEM NÃO EXISTE | ID:", item_id)
		return false

	if quantidade <= 0:
		print("QUANTIDADE INVÁLIDA PARA REMOVER:", quantidade)
		return false

	inventario[item_id]["quantidade"] -= quantidade

	if inventario[item_id]["quantidade"] <= 0:
		inventario.erase(item_id)
		_remover_id_do_layout(item_id)
		print("ITEM REMOVIDO COMPLETAMENTE | ID:", item_id)
	else:
		print("QUANTIDADE REMOVIDA | ID:", item_id, " | Restante:", inventario[item_id]["quantidade"])

	_atualizar_slots_pela_hashmap()
	return true


# Remove o item completo, independentemente da quantidade.
func remover_item_completo(item_id: String) -> bool:
	if not inventario.has(item_id):
		print("NÃO FOI POSSÍVEL REMOVER. ITEM NÃO EXISTE | ID:", item_id)
		return false

	inventario.erase(item_id)
	_remover_id_do_layout(item_id)
	print("ITEM COMPLETO REMOVIDO | ID:", item_id)
	_atualizar_slots_pela_hashmap()
	return true


# Alias em inglês, caso o professor teste o nome padrão da operação.
func remove_item(item_id: String, quantidade: int = 1) -> bool:
	return remover_item(item_id, quantidade)


func remove_item_full(item_id: String) -> bool:
	return remover_item_completo(item_id)


# Extra: permite remover usando o nome, caso o professor teste assim.
func remover_por_nome(nome_item: String, quantidade: int = 1) -> bool:
	var item := consultar_por_nome(nome_item)

	if item.is_empty():
		return false

	return remover_item(str(item["id"]), quantidade)


# ============================================================
# 6) MOVER ITEM ENTRE SLOTS DO INVENTÁRIO
# ============================================================
# A movimentação entre slots altera apenas a ordem visual.
# A HashMap/Dictionary continua sendo a estrutura principal dos dados.
func mover_item_para_slot(item_id: String, indice_destino: int) -> bool:
	if item_id.is_empty():
		return false

	if not inventario.has(item_id):
		print("NÃO FOI POSSÍVEL MOVER. ITEM NÃO EXISTE | ID:", item_id)
		return false

	_garantir_layout_slots()

	if indice_destino < 0 or indice_destino >= ordem_slots.size():
		print("SLOT DE DESTINO INVÁLIDO:", indice_destino)
		return false

	var indice_origem := ordem_slots.find(item_id)

	if indice_origem == -1:
		_colocar_id_no_primeiro_slot_vazio(item_id)
		indice_origem = ordem_slots.find(item_id)

	if indice_origem == indice_destino:
		_atualizar_slots_pela_hashmap()
		return true

	var id_que_estava_no_destino: String = str(ordem_slots[indice_destino])
	ordem_slots[indice_destino] = item_id

	# Se o slot de destino estava vazio, a origem fica vazia.
	# Se estava ocupado, os dois itens trocam de posição.
	if indice_origem >= 0:
		ordem_slots[indice_origem] = id_que_estava_no_destino

	print("ITEM MOVIDO NA INTERFACE | ID:", item_id, " | Slot:", indice_destino)
	_atualizar_slots_pela_hashmap()
	return true


# ============================================================
# 7) DESCARTAR/DROPAR ITEM ARRASTANDO PARA FORA DO INVENTÁRIO
# ============================================================
# O slot visual chama esta função quando o jogador arrasta um item e solta
# fora do painel do inventário.
# A remoção continua sendo feita na HashMap principal e, ao mesmo tempo,
# uma cena drop_item.tscn é criada no chão perto do personagem.
func descartar_item_arrastado(dados: Dictionary, posicao_mouse_tela: Vector2) -> bool:
	if dados.is_empty():
		return false

	# Só descarta se o mouse foi solto fora do painel do inventário.
	# Se soltar dentro do painel, mas fora de um slot, o item continua no inventário.
	if painel != null and painel.get_global_rect().has_point(posicao_mouse_tela):
		return false

	var item_id := str(dados.get("id", ""))

	if item_id.is_empty():
		return false

	if not inventario.has(item_id):
		print("NÃO FOI POSSÍVEL DROPAR. ITEM NÃO EXISTE | ID:", item_id)
		return false

	var item: Dictionary = inventario[item_id]
	var quantidade_drop := int(dados.get("quantidade", item.get("quantidade", 1)))
	quantidade_drop = min(quantidade_drop, int(item.get("quantidade", 0)))

	if quantidade_drop <= 0:
		return false

	if not _criar_drop_no_chao(item, quantidade_drop):
		return false

	remover_item(item_id, quantidade_drop)
	print("ITEM DROPPADO NO CHÃO | ID:", item_id, " | Quantidade:", quantidade_drop)
	return true


func _criar_drop_no_chao(item: Dictionary, quantidade_drop: int) -> bool:
	var jogador = get_tree().get_first_node_in_group("player")

	if jogador == null or not (jogador is Node2D):
		print("PLAYER NÃO ENCONTRADO PARA DROPAR ITEM NO CHÃO")
		return false

	var drop = DROP_ITEM_SCENE.instantiate()
	drop.set("item_id", str(item.get("id", "")))
	drop.set("item_name", str(item.get("nome", _nome_amigavel(str(item.get("id", ""))))))
	drop.set("item_texture", item.get("textura", null))
	drop.set("quantidade", quantidade_drop)
	drop.set("pickup_delay", 0.45)

	# Coloca o drop no mesmo mundo/pai do jogador para ele aparecer no chão.
	var pai_mundo: Node = jogador.get_parent()
	if pai_mundo == null:
		pai_mundo = get_tree().current_scene

	if pai_mundo == null:
		return false

	pai_mundo.add_child(drop)

	# Nasce um pouco abaixo do personagem para não ser coletado instantaneamente.
	drop.global_position = (jogador as Node2D).global_position + Vector2(0, 30)
	return true


# ============================================================
# FUNÇÃO DE DEMONSTRAÇÃO PARA O PROFESSOR
# ============================================================
# Esta função não é chamada automaticamente para não alterar o jogo.
# Ela serve para mostrar, em código, todas as operações pedidas:
# adicionar, consultar por ID, consultar por nome, exibir e remover.
func demonstrar_funcoes_professor() -> void:
	adicionar_item("slime_gel", "Gel de Slime", preload("res://characters/assets/slime_gel.png"), 2)
	consultar_por_id("slime_gel")
	consultar_por_nome("Gel de Slime")
	exibir_inventario()
	remover_item("slime_gel", 1)
	remover_item_completo("slime_gel")
	exibir_inventario()


# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================
func _atualizar_slots_pela_hashmap() -> void:
	# A UI não é a estrutura principal. Ela apenas mostra o conteúdo
	# que está armazenado na HashMap inventario.
	_garantir_layout_slots()
	_limpar_ids_invalidos_do_layout()

	for slot in lista.get_children():
		if slot.has_method("limpar_item"):
			slot.limpar_item()

	var slots := lista.get_children()

	for indice in range(min(slots.size(), ordem_slots.size())):
		var id := str(ordem_slots[indice])

		if id.is_empty() or not inventario.has(id):
			continue

		var item: Dictionary = inventario[id]
		var slot = slots[indice]

		if slot.has_method("colocar_item"):
			slot.colocar_item(
				item.get("textura", null),
				str(item["nome"]),
				int(item["quantidade"]),
				str(item["id"])
			)


func _garantir_layout_slots() -> void:
	if lista == null:
		return

	var total_slots := lista.get_child_count()

	while ordem_slots.size() < total_slots:
		ordem_slots.append("")

	while ordem_slots.size() > total_slots:
		ordem_slots.pop_back()


func _colocar_id_no_primeiro_slot_vazio(item_id: String) -> bool:
	_garantir_layout_slots()

	if _id_esta_no_layout(item_id):
		return true

	for indice in range(ordem_slots.size()):
		if str(ordem_slots[indice]).is_empty():
			ordem_slots[indice] = item_id
			return true

	print("NÃO HÁ SLOT VAZIO PARA EXIBIR O ITEM:", item_id)
	return false


func _id_esta_no_layout(item_id: String) -> bool:
	return ordem_slots.find(item_id) != -1


func _remover_id_do_layout(item_id: String) -> void:
	_garantir_layout_slots()

	for indice in range(ordem_slots.size()):
		if str(ordem_slots[indice]) == item_id:
			ordem_slots[indice] = ""


func _limpar_ids_invalidos_do_layout() -> void:
	_garantir_layout_slots()

	for indice in range(ordem_slots.size()):
		var id := str(ordem_slots[indice])

		if not id.is_empty() and not inventario.has(id):
			ordem_slots[indice] = ""

	# Se algum item existir na HashMap mas ainda não tiver posição visual,
	# coloca no primeiro slot vazio.
	for id in inventario.keys():
		var item_id := str(id)
		if not _id_esta_no_layout(item_id):
			_colocar_id_no_primeiro_slot_vazio(item_id)


func _nome_amigavel(item_id: String) -> String:
	match item_id:
		"slime_gel":
			return "Gel de Slime"
		"sword":
			return "Espada"
		_:
			return item_id.capitalize().replace("_", " ")
