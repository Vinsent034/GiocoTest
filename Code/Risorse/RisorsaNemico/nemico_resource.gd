extends Resource
class_name NemicoResource

## Tipo comportamentale: come si muove/attacca il nemico
enum TipoComportamento {
	INSEGUITORE,  ## Si avvicina al player
	SCATTATORE,   ## Si muove a scatti veloci
	TIRATORE,     ## Attacca a distanza
}

## Tipo di ruolo: caratteristica di combattimento del nemico
enum TipoRuolo {
	TANK,      ## Alta vita, bassa velocità
	EVASIVO,   ## Bassa vita, alta velocità
	ASSASSINO, ## Alto attacco, bassa difesa
	NORMALE,   ## Bilanciato in tutto
}

@export var attacco: int = 10
@export var difesa: int = 5
@export var velocita: float = 100.0
@export var salute_massima: int = 50
@export var raggio_inseguimento: float = 200.0
@export var raggio_attacco: float = 30.0
@export var ritardo_attacco: float = 1.0

@export var tipo_comportamento: TipoComportamento = TipoComportamento.INSEGUITORE
@export var tipo_ruolo: TipoRuolo = TipoRuolo.TANK

## Dati animazione collegati a questo nemico
@export var animazioni: AnimationData
