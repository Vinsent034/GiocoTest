extends Node

const MAX_ISTANZE_PER_SCENA: int = 50

# Dizionario: PackedScene -> Array[Nemico]
var _pool: Dictionary = {}
# Contatore istanze totali per scena (in pool + attive)
var _contatore: Dictionary = {}


func preleva(scena: PackedScene, parent: Node, posizione: Vector2) -> Nemico:
	if not _pool.has(scena):
		_pool[scena] = []
	if not _contatore.has(scena):
		_contatore[scena] = 0

	var lista: Array = _pool[scena]
	var nemico: Nemico = null

	while lista.size() > 0:
		var candidato = lista.pop_back()
		if is_instance_valid(candidato):
			nemico = candidato
			break
		else:
			# L'istanza non è più valida, aggiorna il contatore
			_contatore[scena] = max(0, _contatore[scena] - 1)

	if not nemico:
		if _contatore[scena] >= MAX_ISTANZE_PER_SCENA:
			# Limite raggiunto: non creare nuove istanze
			return null
		nemico = scena.instantiate() as Nemico
		parent.add_child(nemico)
		_contatore[scena] += 1

	nemico._scena_pool = scena
	nemico.reimposta(posizione)
	return nemico


func restituisci(nemico: Nemico) -> void:
	if not nemico._scena_pool:
		nemico.queue_free()
		return
	if not _pool.has(nemico._scena_pool):
		_pool[nemico._scena_pool] = []
	_pool[nemico._scena_pool].append(nemico)
