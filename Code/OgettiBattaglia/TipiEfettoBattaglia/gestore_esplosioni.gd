extends Node2D
class_name GestoreEsplosioni

@export var player: Node2D
@export var esplosioni: Array[Esplosione] = []
@export var raggio: float = 100.0
@export var contatore_attive: int = 3
@export var intervallo: float = 3.0

var _timer: Timer


func _ready() -> void:
	if not player:
		push_error("GestoreEsplosioni: player non assegnato!")
		return

	_timer = Timer.new()
	_timer.wait_time = intervallo
	_timer.autostart = false
	add_child(_timer)
	_timer.timeout.connect(ridistribuisci)
	_timer.start()
	ridistribuisci()


func ridistribuisci() -> void:
	var attive := clampi(contatore_attive, 0, esplosioni.size())
	var pos_base := player.global_position

	for i in esplosioni.size():
		if i < attive:
			esplosioni[i].attiva(pos_base + _posizione_random())
		else:
			esplosioni[i]._disattiva()


func _posizione_random() -> Vector2:
	var angolo := randf() * TAU
	var distanza := randf() * raggio
	return Vector2(cos(angolo), sin(angolo)) * distanza
