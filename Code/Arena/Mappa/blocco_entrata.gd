extends Node2D

@export var area: Area2D


func _ready() -> void:
	if area:
		area.body_entered.connect(_su_corpo_entrato)


func _su_corpo_entrato(corpo: Node2D) -> void:
	if corpo is Player:
		Global.entra_arena.emit()
