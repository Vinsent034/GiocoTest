extends Node

@onready var label: Label = $Label

func _ready() -> void:
	label.text = str(ManagerRaccolata.oro_totale)
	ManagerRaccolata.oro_raccolto.connect(_on_oro_raccolto)

func _on_oro_raccolto(_valore: int) -> void:
	label.text = str(ManagerRaccolata.oro_totale)
