extends Panel

@onready var icone = $TextureRect

var item_texture: Texture2D = null
var item_name: String = ""
var item_id: String = ""
var quantidade: int = 0
var quantidade_label: Label = null
var _dados_do_drag: Dictionary = {}


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_criar_label_quantidade()
	_atualizar_label_quantidade()

	# O slot precisa receber eventos de mouse para aceitar drop interno.
	mouse_filter = Control.MOUSE_FILTER_STOP

	if icone:
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _criar_label_quantidade() -> void:
	quantidade_label = get_node_or_null("QuantidadeLabel")

	if quantidade_label == null:
		quantidade_label = Label.new()
		quantidade_label.name = "QuantidadeLabel"
		add_child(quantidade_label)

	quantidade_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quantidade_label.anchor_left = 0.0
	quantidade_label.anchor_top = 0.0
	quantidade_label.anchor_right = 1.0
	quantidade_label.anchor_bottom = 1.0
	quantidade_label.offset_left = 0.0
	quantidade_label.offset_top = 0.0
	quantidade_label.offset_right = -4.0
	quantidade_label.offset_bottom = -3.0
	quantidade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantidade_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	quantidade_label.add_theme_font_size_override("font_size", 14)
	quantidade_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	quantidade_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	quantidade_label.add_theme_constant_override("shadow_offset_x", 1)
	quantidade_label.add_theme_constant_override("shadow_offset_y", 1)


func colocar_item(textura: Texture2D, nome: String = "", qtd: int = 1, id: String = "") -> void:
	item_texture = textura
	item_name = nome
	item_id = id
	quantidade = qtd

	icone.texture = textura
	icone.visible = textura != null

	_atualizar_label_quantidade()


func adicionar_quantidade(qtd: int = 1) -> void:
	quantidade += qtd
	_atualizar_label_quantidade()
	_animar_stack()


func tem_item(nome: String) -> bool:
	return item_texture != null and item_name == nome


func tem_item_id(id: String) -> bool:
	return item_id == id and item_name != ""


func limpar_item() -> void:
	item_texture = null
	item_name = ""
	item_id = ""
	quantidade = 0

	icone.texture = null
	icone.visible = false

	_atualizar_label_quantidade()


func _atualizar_label_quantidade() -> void:
	if quantidade_label == null:
		return

	# Mostra o número somente quando tiver 2 ou mais no stack.
	if item_texture != null and quantidade > 1:
		quantidade_label.text = str(quantidade)
		quantidade_label.visible = true
	else:
		quantidade_label.text = ""
		quantidade_label.visible = false


func _animar_stack() -> void:
	if icone == null:
		return

	icone.scale = Vector2(1.18, 1.18)
	var tween := create_tween()
	tween.tween_property(icone, "scale", Vector2.ONE, 0.10)


func _on_mouse_entered() -> void:
	if item_texture != null:
		scale = Vector2(1.06, 1.06)


func _on_mouse_exited() -> void:
	scale = Vector2.ONE


func _get_drag_data(_at_position):
	if item_texture == null or item_id.is_empty():
		return null

	var preview = TextureRect.new()
	preview.texture = item_texture
	preview.custom_minimum_size = Vector2(42, 42)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)

	_dados_do_drag = {
		"texture": item_texture,
		"nome": item_name,
		"id": item_id,
		"quantidade": quantidade,
		"origem": self
	}

	return _dados_do_drag


func _notification(what: int) -> void:
	if what != NOTIFICATION_DRAG_END:
		return

	if _dados_do_drag.is_empty():
		return

	var dados := _dados_do_drag.duplicate()
	_dados_do_drag.clear()

	# Se o drag foi aceito por outro slot, não descarta.
	if is_drag_successful():
		return

	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("descartar_item_arrastado"):
		inventario_ui.descartar_item_arrastado(dados, get_global_mouse_position())


func _can_drop_data(_position, data) -> bool:
	# Agora os slots aceitam drops internos.
	# Isso permite mudar um item para outro slot e impede que o Godot trate
	# a troca de slot como se fosse descarte no chão.
	if not (data is Dictionary):
		return false

	return str(data.get("id", "")) != ""


func _drop_data(_position, data) -> void:
	if not (data is Dictionary):
		return

	var id := str(data.get("id", ""))
	if id.is_empty():
		return

	var inventario_ui = get_tree().get_first_node_in_group("inventario")

	if inventario_ui and inventario_ui.has_method("mover_item_para_slot"):
		inventario_ui.mover_item_para_slot(id, get_index())
