extends Node

const PERCORSO := "user://salvataggio.cfg"


func esiste() -> bool:
	return FileAccess.file_exists(PERCORSO)


func salva(gestore: Node) -> void:
	var cfg := ConfigFile.new()
	var p := Global.player
	var sp := Global.stat_player

	cfg.set_value("arena", "livello", gestore.Livello)
	cfg.set_value("arena", "indice_mappa", gestore._indice_corrente)

	cfg.set_value("risorse", "oro_totale", ManagerRaccolata.oro_totale)

	cfg.set_value("player", "salute", p.salute)
	cfg.set_value("player", "salute_massima", p.salute_massima)
	cfg.set_value("player", "velocita", p.velocita)
	cfg.set_value("player", "potenza_attacco", p.potenza_attacco)
	cfg.set_value("player", "attacco", p.attacco)
	cfg.set_value("player", "difesa", p.difesa)
	cfg.set_value("player", "schivata", p.schivata)
	cfg.set_value("player", "critico", p.critico)
	cfg.set_value("player", "fortuna", p.fortuna)

	cfg.set_value("stat_player", "base_potenza_attacco", sp._base_potenza_attacco)
	cfg.set_value("stat_player", "base_velocita", sp._base_velocita)
	cfg.set_value("stat_player", "scaglioni_attacco", sp._scaglioni_attacco)
	cfg.set_value("stat_player", "scaglioni_velocita", sp._scaglioni_velocita)

	cfg.save(PERCORSO)


func carica(gestore: Node) -> void:
	if not esiste():
		return
	var cfg := ConfigFile.new()
	if cfg.load(PERCORSO) != OK:
		return

	gestore.Livello = cfg.get_value("arena", "livello", 1)
	gestore._indice_corrente = cfg.get_value("arena", "indice_mappa", 0)
	gestore.LivelloL.text = "Piano: " + str(gestore.Livello)

	ManagerRaccolata.oro_totale = cfg.get_value("risorse", "oro_totale", 0)
	ManagerRaccolata.oro_raccolto.emit(0)

	var p := Global.player
	p.salute_massima  = cfg.get_value("player", "salute_massima", p.salute_massima)
	p.velocita        = cfg.get_value("player", "velocita", p.velocita)
	p.potenza_attacco = cfg.get_value("player", "potenza_attacco", p.potenza_attacco)
	p.attacco         = cfg.get_value("player", "attacco", p.attacco)
	p.difesa          = cfg.get_value("player", "difesa", p.difesa)
	p.schivata        = cfg.get_value("player", "schivata", p.schivata)
	p.critico         = cfg.get_value("player", "critico", p.critico)
	p.fortuna         = cfg.get_value("player", "fortuna", p.fortuna)
	p.salute          = cfg.get_value("player", "salute", p.salute_massima)
	p._aggiorna_barra_vita()

	var sp := Global.stat_player
	sp._base_potenza_attacco = cfg.get_value("stat_player", "base_potenza_attacco", p.potenza_attacco)
	sp._base_velocita        = cfg.get_value("stat_player", "base_velocita", p.velocita)
	sp._scaglioni_attacco    = cfg.get_value("stat_player", "scaglioni_attacco", 0)
	sp._scaglioni_velocita   = cfg.get_value("stat_player", "scaglioni_velocita", 0)


func cancella() -> void:
	if esiste():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PERCORSO))
