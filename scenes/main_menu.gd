extends Control

func _ready():
	pass

func _on_start_game_pressed():
	print("Start button pressed!")  # Just to confirm it runs
	get_tree().change_scene_to_file("res://Opening_Cutscene.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_button_pressed() -> void:
	pass
