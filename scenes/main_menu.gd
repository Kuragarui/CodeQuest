extends Control

func _ready():
	pass

func _on_start_game_pressed():
	# Change the path to match where your game.tscn is located
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_button_pressed() -> void:
	pass # Replace with function body.
