extends CanvasLayer
class_name TransizioneVerticale

signal tween_completato

@export var durata: float = 1.0

@onready var pannello: ColorRect = $ColorRect


func _ready() -> void:
	pannello.position.y = -pannello.size.y
	Global.AvviaTween.connect(entra)


func entra() -> void:
	visible = true
	pannello.position.y = -pannello.size.y
	if Global.player:
		Global.player.remove_from_group("Player")
	var tween := create_tween()
	tween.tween_property(pannello, "position:y", 0.0, durata)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): tween_completato.emit())


func esci() -> void:
	var tween := create_tween()
	tween.tween_property(pannello, "position:y", pannello.size.y, durata)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		visible = false
		if Global.player:
			Global.player.add_to_group("Player")
	)
