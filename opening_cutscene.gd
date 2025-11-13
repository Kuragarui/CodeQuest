extends Node2D

@onready var fade = $CanvasLayer/FadeControl
@onready var title_image = $CanvasLayer/TitleImage
@onready var proceed_button = $CanvasLayer/ProceedButton

var cutscene_done := false

func _ready() -> void:
	print("Opening cutscene _ready() called")
	
	# Initially hide the proceed button
	proceed_button.visible = false
	
	# Connect proceed button
	proceed_button.pressed.connect(_on_proceed_button_pressed)
	print("Proceed button connected")
	
	# Connect to the GLOBAL DialogueManager autoload (not a scene node)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	print("Connected to global DialogueManager")
	
	# Start the dialogue
	var dialogue_res = load("res://Dialogue/opening_backstory.dialogue")
	DialogueManager.show_example_dialogue_balloon(dialogue_res, "start")
	print("Dialogue started")

func _on_dialogue_ended(resource: DialogueResource) -> void:
	print("Dialogue ended signal received!")
	
	# Only respond to this cutscene
	if resource.resource_path != "res://Dialogue/opening_backstory.dialogue":
		return
	
	if cutscene_done:
		return
	
	cutscene_done = true
	
	# Show the proceed button
	proceed_button.visible = true
	print("Proceed button is now visible")

func _on_proceed_button_pressed() -> void:
	print("Proceed button pressed")
	_fade_and_change_scene("res://scenes/game.tscn")

func _fade_and_change_scene(scene_path: String) -> void:
	var fade_out = create_tween()
	fade_out.tween_property(fade, "modulate:a", 1.0, 2.0)
	fade_out.tween_property(title_image, "modulate:a", 0.0, 2.0)
	await fade_out.finished
	
	print("Changing scene to:", scene_path)
	get_tree().change_scene_to_file(scene_path)
