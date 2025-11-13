extends Button

func _ready():
	hide() # In case the button is visible at start

func _on_proceed_button_pressed():
	print("Proceed button pressed! Switching to main game scene.")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
