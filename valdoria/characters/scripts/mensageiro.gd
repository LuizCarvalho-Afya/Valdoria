extends CharacterBody2D

@onready var speech_bubble = $CanvasGroup
@onready var label = $CanvasGroup/Label 

func _ready():
	if speech_bubble:
		speech_bubble.hide()

	if label:
		# Isso limpa qualquer configuração que esteja travando o tamanho
		label.label_settings = LabelSettings.new()

		label.label_settings.font_size = 30 # Mude esse número para o tamanho que quiser

		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2(900, 1200) # Define uma largura mínima para o balão

func _on_chat_detection_body_entered(body):
	if body.is_in_group("player"):
		show_dialogue("Sabia que o Slime Assassino não tem órgãos? Ele é basicamente um estômago gigante com sede de sangue. Fascinante, não?")

func _on_chat_detection_body_exited(body):
	if body.is_in_group("player"):
		speech_bubble.hide()

func show_dialogue(text: String):
	label.text = text
	speech_bubble.show()
