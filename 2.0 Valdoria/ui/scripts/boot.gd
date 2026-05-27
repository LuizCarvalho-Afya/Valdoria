extends Node

const MAIN_MENU_SCENE: String = "res://ui/scenes/main_menu.tscn"

var _menu_was_requested: bool = false


func _ready() -> void:
	# Garante que a tela inicial apareça mesmo se o projeto estiver
	# abrindo a última cena usada no editor ou se o usuário apertar F6.
	call_deferred("_open_main_menu_once")


func _open_main_menu_once() -> void:
	if _menu_was_requested:
		return

	var current := get_tree().current_scene
	if current == null:
		call_deferred("_open_main_menu_once")
		return

	if current.scene_file_path == MAIN_MENU_SCENE:
		_menu_was_requested = true
		return

	_menu_was_requested = true
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
