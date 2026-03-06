extends Node

signal oro_raccolto(valore: int)
signal exp_raccolta(valore: int)
signal bistecca_raccolta(valore: int)
signal livello_su(token: int)
signal oro_cassaforte_aggiornato(nuovo_totale: int)

var oro_totale: int = 0
var exp_totale: int = 0
var oro_cassaforte: int = 0


func raccogli(tipo: int, valore: int) -> void:
	match tipo:
		0: # ORO
			oro_totale += valore
			oro_raccolto.emit(valore)
		1: # EXP
			exp_totale += valore
			exp_raccolta.emit(valore)
		2: # BISTECCA
			bistecca_raccolta.emit(valore)


func trasferisci_oro_in_cassaforte() -> void:
	oro_cassaforte += oro_totale
	oro_totale = 0
	oro_raccolto.emit(0)
	oro_cassaforte_aggiornato.emit(oro_cassaforte)
