extends Node2D

@export var ray_cast: RayCast2D
@export var scena_freccia: PackedScene
@export var cadenza_sparo: float = 0.5
@export var raggio_mira: float = 200.0

var _timer_sparo: float = 0.0

func _physics_process(delta: float) -> void:
	var nemico_vicino := trova_nemico_piu_vicino()
	if nemico_vicino:
		var direzione := (nemico_vicino.global_position - global_position).normalized()
		ray_cast.target_position = direzione * ray_cast.target_position.length()
	else:
		ray_cast.target_position = Vector2.RIGHT * ray_cast.target_position.length()

	_timer_sparo -= delta
	if nemico_vicino and _timer_sparo <= 0.0:
		spara(nemico_vicino)
		_timer_sparo = cadenza_sparo


func spara(bersaglio: Nemico) -> void:
	if not scena_freccia:
		return
	var freccia := scena_freccia.instantiate()
	freccia.global_position = global_position
	freccia.direzione = (bersaglio.global_position - global_position).normalized()
	get_tree().current_scene.add_child(freccia)


func trova_nemico_piu_vicino() -> Nemico:
	var nemici := get_tree().get_nodes_in_group("Nemici")
	var piu_vicino: Nemico = null
	var distanza_minima := INF
	for nodo in nemici:
		if nodo is Nemico:
			var dist := global_position.distance_to(nodo.global_position)
			if dist < distanza_minima and dist <= raggio_mira:
				distanza_minima = dist
				piu_vicino = nodo
	return piu_vicino
