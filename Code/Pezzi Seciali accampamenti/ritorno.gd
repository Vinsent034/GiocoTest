extends StaticBody2D
class_name Ritorno_a_casa

@onready var menu: Control = $MappaOpzionalità


func _ready() -> void:
	menu.visible = false


func Proposta(area: Area2D) -> void:
	menu.visible = true


func Ritorna() -> void:
	SaveManager.cancella()
	SceneManager.vai_alla_home()


func Continua() -> void:
	menu.visible = false
