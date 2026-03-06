extends Node

const PERCORSO := "user://cassaforte.cfg"


func _ready() -> void:
	carica()


func salva() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("cassaforte", "oro", ManagerRaccolata.oro_cassaforte)
	cfg.save(PERCORSO)


func carica() -> void:
	if not FileAccess.file_exists(PERCORSO):
		return
	var cfg := ConfigFile.new()
	if cfg.load(PERCORSO) != OK:
		return
	ManagerRaccolata.oro_cassaforte = cfg.get_value("cassaforte", "oro", 0)
