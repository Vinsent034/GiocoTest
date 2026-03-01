extends Node

signal rilascio_id(id: int)
signal entra_arena
signal AvviaTween
signal TuttiINemiciAbbattuti
signal mappa_cambiata

var player: Player = null
var stat_player: StatPlayer = null

var RiferiemntoMappa: Mappa = null
var LivelloPiano : int = 1