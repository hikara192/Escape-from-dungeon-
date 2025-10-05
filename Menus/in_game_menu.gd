extends CanvasLayer

@onready var score = $Score
@onready var hi_score = $HiScore


func _on_exit_mm_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
	
func _process(delta: float) -> void:
	if not score or not hi_score: 
		return
	$Score.text = "" + str( GlobalVars.score )
	$HiScore.text = "" + str( GlobalVars.hi_score )
