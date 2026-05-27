extends Control

const GAME_SCENE_PATH: String = "res://levels/scenes/test_level.tscn"

@onready var controls_panel: Panel = $ControlsPanel
@onready var play_button: Button = $ButtonLayer/PlayButton
@onready var controls_button: Button = $ButtonLayer/ControlsButton
@onready var exit_button: Button = $ButtonLayer/ExitButton
@onready var back_button: Button = $ControlsPanel/BackButton


func _ready() -> void:
	controls_panel.hide()

	play_button.pressed.connect(_on_play_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and controls_panel.visible:
		controls_panel.hide()
		get_viewport().set_input_as_handled()


func _on_play_pressed() -> void:
	_start_game()


func _on_controls_pressed() -> void:
	controls_panel.visible = not controls_panel.visible


func _on_back_pressed() -> void:
	controls_panel.hide()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
