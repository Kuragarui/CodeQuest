extends Control

var can_skip: bool = false

func _ready() -> void:
	# Allow skipping after 2 seconds
	await get_tree().create_timer(2.0).timeout
	can_skip = true
	
	# Auto-advance after 8 seconds
	await get_tree().create_timer(6.0).timeout
	_go_to_menu()

func _input(event: InputEvent) -> void:
	if can_skip and event.is_pressed():
		_go_to_menu()

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
