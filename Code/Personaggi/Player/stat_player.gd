extends Node
class_name StatPlayer

@export var player: Player

# Valori base salvati all'avvio per calcolare le percentuali
var _base_potenza_attacco: int = 0
var _base_velocita: float = 0.0
# Contatori scaglioni percentuali (separati da player.attacco che è il bonus piatto)
var _scaglioni_attacco: int = 0
var _scaglioni_velocita: int = 0

func _ready() -> void:
	Global.stat_player = self
	_base_potenza_attacco = player.potenza_attacco
	_base_velocita = player.velocita

# --- Funzioni di aumento stat ------------------------------------------------

func aumenta_vita_massima(valore: int) -> void:
	player.salute_massima += valore
	player.salute += valore
	player._aggiorna_barra_vita()


# valore = numero di scaglioni da 10% (positivo o negativo)
func aumenta_attacco(valore: int) -> void:
	_scaglioni_attacco += valore
	player.potenza_attacco = int(_base_potenza_attacco * (1.0 + _scaglioni_attacco * 0.1))


func aumenta_potenza_attacco(valore: int) -> void:
	player.potenza_attacco += valore


func aumenta_difesa(valore: int) -> void:
	player.difesa += valore


func aumenta_schivata(valore: int) -> void:
	player.schivata += valore


func aumenta_critico(valore: int) -> void:
	player.critico += valore


func aumenta_fortuna(valore: int) -> void:
	player.fortuna += valore


# valore = numero di scaglioni da 10% (positivo o negativo)
func aumenta_velocita(valore: int) -> void:
	_scaglioni_velocita += valore
	player.velocita = _base_velocita * (1.0 + _scaglioni_velocita * 0.1)
