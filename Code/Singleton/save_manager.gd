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
	cfg.set_value("risorse", "exp_totale", ManagerRaccolata.exp_totale)

	for key in p.to_save_dict():
		cfg.set_value("player", key, p.to_save_dict()[key])

	for key in sp.to_save_dict():
		cfg.set_value("stat_player", key, sp.to_save_dict()[key])

	var bonus := gestore.get_node_or_null("SetLayer/Bonus Statistiche Partite") as BonusStatistichePartita
	if bonus:
		cfg.set_value("bonus", "vita", bonus.vita)
		cfg.set_value("bonus", "attacco", bonus.attacco)
		cfg.set_value("bonus", "difesa", bonus.difesa)
		cfg.set_value("bonus", "critico", bonus.critico)
		cfg.set_value("bonus", "elusione", bonus.elusione)
		cfg.set_value("bonus", "velocita", bonus.velocita)
		cfg.set_value("bonus", "fortuna", bonus.fortuna)
		cfg.set_value("bonus", "punti_rimanenti", bonus._punti_rimanenti)
		cfg.set_value("bonus", "min_vita", bonus._min_vita)
		cfg.set_value("bonus", "min_attacco", bonus._min_attacco)
		cfg.set_value("bonus", "min_difesa", bonus._min_difesa)
		cfg.set_value("bonus", "min_critico", bonus._min_critico)
		cfg.set_value("bonus", "min_elusione", bonus._min_elusione)
		cfg.set_value("bonus", "min_velocita", bonus._min_velocita)
		cfg.set_value("bonus", "min_fortuna", bonus._min_fortuna)

	cfg.save(PERCORSO)


func carica(gestore: Node) -> void:
	if not esiste():
		return
	var cfg := ConfigFile.new()
	if cfg.load(PERCORSO) != OK:
		return
	if not Global.player or not Global.stat_player:
		push_warning("SaveManager: player/stat_player non ancora pronti")
		return

	gestore.Livello = cfg.get_value("arena", "livello", 1)
	gestore._indice_corrente = cfg.get_value("arena", "indice_mappa", 0)
	gestore.LivelloL.text = "Piano: " + str(gestore.Livello)

	ManagerRaccolata.oro_totale = cfg.get_value("risorse", "oro_totale", 0)
	ManagerRaccolata.oro_raccolto.emit(0)
	ManagerRaccolata.exp_totale = cfg.get_value("risorse", "exp_totale", 0)

	var p := Global.player
	var p_data := {}
	for key in cfg.get_section_keys("player"):
		p_data[key] = cfg.get_value("player", key)
	p.from_save_dict(p_data)

	var sp := Global.stat_player
	var sp_data := {}
	for key in cfg.get_section_keys("stat_player"):
		sp_data[key] = cfg.get_value("stat_player", key)
	sp.from_save_dict(sp_data)

	var bonus := gestore.get_node_or_null("SetLayer/Bonus Statistiche Partite") as BonusStatistichePartita
	if bonus:
		bonus.vita              = cfg.get_value("bonus", "vita", 0)
		bonus.attacco           = cfg.get_value("bonus", "attacco", 0)
		bonus.difesa            = cfg.get_value("bonus", "difesa", 0)
		bonus.critico           = cfg.get_value("bonus", "critico", 0)
		bonus.elusione          = cfg.get_value("bonus", "elusione", 0)
		bonus.velocita          = cfg.get_value("bonus", "velocita", 0)
		bonus.fortuna           = cfg.get_value("bonus", "fortuna", 0)
		bonus._punti_rimanenti  = cfg.get_value("bonus", "punti_rimanenti", bonus.punti_abilitati)
		bonus._min_vita         = cfg.get_value("bonus", "min_vita", 0)
		bonus._min_attacco      = cfg.get_value("bonus", "min_attacco", 0)
		bonus._min_difesa       = cfg.get_value("bonus", "min_difesa", 0)
		bonus._min_critico      = cfg.get_value("bonus", "min_critico", 0)
		bonus._min_elusione     = cfg.get_value("bonus", "min_elusione", 0)
		bonus._min_velocita     = cfg.get_value("bonus", "min_velocita", 0)
		bonus._min_fortuna      = cfg.get_value("bonus", "min_fortuna", 0)
		bonus._aggiorna_ui()


func cancella() -> void:
	if esiste():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PERCORSO))
