extends Control

func _on_retry_pressed() -> void:
	print("Retry button pressed!")
	PlayerStats.reset_health()  # Reset health before retrying
	get_tree().change_scene_to_file("res://scenes/second_dungeon.tscn")

func _on_main_menu_pressed() -> void:
	print("Menu button pressed!")
	PlayerStats.reset_health()  # Reset health
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
