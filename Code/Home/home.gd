extends Node2D
class_name Home

func GiocaArena(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		SceneManager.vai_all_arena()
