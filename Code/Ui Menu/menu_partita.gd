extends Control
class_name MenuPartita

@export var Bottone_apri_menu : TextureButton
@export var Scena_arena: ArenaGame


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Bottone_apri_menu != null:
		Bottone_apri_menu.pressed.connect(ApriMenu)


# le seguenti funzioni sono collegate manualmente ai segnali button_pressed dalla sezione segnali

func Riprendi_partita():
	visible = false
	Scena_arena.process_mode = Node.PROCESS_MODE_INHERIT


func Impostazioni_partita():
	pass
	# da implementare in futuro non ora

func Statistiche_partita():
	var p := Global.player
	if p == null:
		return
	print("=== Statistiche Player ===")
	print("Salute: %d / %d" % [p.salute, p.salute_massima])
	print("Velocita: %.1f" % p.velocita)
	print("Potenza attacco: %d" % p.potenza_attacco)
	print("Difesa: %d" % p.difesa)
	print("Schivata: %d%%" % p.schivata)
	print("Critico: %d%%" % p.critico)
	print("Fortuna: %d" % p.fortuna)
	print("Oro: %d" % ManagerRaccolata.oro_totale)


func Esci_partita():
	ManagerRaccolata.oro_totale = 0
	ManagerRaccolata.oro_raccolto.emit(0)
	Scena_arena.process_mode = Node.PROCESS_MODE_INHERIT
	SaveManager.cancella()
	SceneManager.vai_alla_home()


func ApriMenu():
	visible = true
	Scena_arena.process_mode = Node.PROCESS_MODE_DISABLED
