extends Control

func _ready() -> void:
	$PausePanelContainer.visible = false
	get_tree().paused = false

func _on_pause_btn_pressed() -> void:
	get_tree().paused = true
	$PausePanelContainer.visible = true
	print("Pause button pressed.")

func _on_resume_pressed() -> void:
	get_tree().paused = false
	$PausePanelContainer.visible = false
	print("Resumed")

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
