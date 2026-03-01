extends VBoxContainer
class_name QuestArena

@export var icone_nemici: Array[TextureRect] = []
@export var spawner: Node

signal piano_completato

# Quanti nemici di ogni tipo devono essere sconfitti (indice = slot)
var conteggi: Array[int] = []
# Quanti ne sono stati uccisi per ogni slot
var uccisi: Array[int] = []
# Carte attive, tenute per confrontare l'id al momento della morte
var _carte: Array[CartaNemico] = []


func _ready() -> void:
	Global.rilascio_id.connect(_su_nemico_morto)
	Global.mappa_cambiata.connect(reinizializza)
	reinizializza()


func reinizializza() -> void:
	var mappa := Global.RiferiemntoMappa
	if mappa == null:
		return

	_carte = mappa.get_carte_nemici()
	if _carte.is_empty():
		return
	conteggi = _distribuisci(mappa.Max_nemici_Spaun, _carte.size())
	uccisi.clear()
	uccisi.resize(_carte.size())

	# Aggiorna UI
	for i in icone_nemici.size():
		var rect := icone_nemici[i]
		if rect == null:
			continue
		if i < _carte.size():
			rect.texture = _carte[i].immagine
			rect.visible = true
			var label := rect.get_node_or_null("Label") as Label
			if label:
				label.text = "0/" + str(conteggi[i])
		else:
			rect.visible = false

	# Costruisce la coda e la passa allo spawner
	if spawner:
		spawner.reinizializza()
		var coda: Array[CartaNemico] = _costruisci_coda(_carte, conteggi)
		spawner.inizializza(coda)


func _su_nemico_morto(id: int) -> void:
	for i in _carte.size():
		if _carte[i].ID_nemico == id:
			uccisi[i] += 1
			var rect := icone_nemici[i] if i < icone_nemici.size() else null
			if rect == null:
				return
			var label := rect.get_node_or_null("Label") as Label
			if label:
				label.text = str(uccisi[i]) + "/" + str(conteggi[i])
			if uccisi.reduce(func(a, b): return a + b, 0) >= conteggi.reduce(func(a, b): return a + b, 0):
				piano_completato.emit()
				Global.TuttiINemiciAbbattuti.emit()
			return


# Costruisce l'array piatto: ogni CartaNemico ripetuta N volte secondo i conteggi
func _costruisci_coda(carte: Array[CartaNemico], counts: Array[int]) -> Array[CartaNemico]:
	var coda: Array[CartaNemico] = []
	for i in carte.size():
		for _j in counts[i]:
			coda.append(carte[i])
	return coda


# Distribuisce 'totale' unità in 'quanti' slot in modo casuale (almeno 1 per slot)
func _distribuisci(totale: int, quanti: int) -> Array[int]:
	var risultato: Array[int] = []
	risultato.resize(quanti)
	for i in quanti:
		risultato[i] = 1
	var rimasti := totale - quanti
	for _i in rimasti:
		var slot := randi_range(0, quanti - 1)
		risultato[slot] += 1
	return risultato
