extends Node2D

var is_interacting = false
var npc_name = "Guider Elden"

@onready var animated_sprite = $AnimatedSprite2D
@onready var interact_area = $Area2D

func _ready():
	# Connect Area2D signals
	interact_area.body_entered.connect(_on_Area2D_body_entered)
	interact_area.body_exited.connect(_on_Area2D_body_exited)

	# Listen for dialogue end globally (from DialogueManager)
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_finished):
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and not is_interacting:
		is_interacting = true
		show_dialog()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		is_interacting = false
		close_dialog()
		print(npc_name + ": Farewell, adventurer!")

func show_dialog():
	var dialogue_resource = load("res://Dialogue/guider_dialogue.dialogue")
	DialogueManager.set_meta("current_npc", self)

	# Show the balloon (returns the balloon CanvasLayer)
	var balloon = DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")
	
	# Optional: Keep a reference so we can close it later
	DialogueManager.set_meta("current_balloon", balloon)

func _on_dialogue_finished():
	is_interacting = false
	close_dialog()

func close_dialog():
	var balloon = DialogueManager.get_meta("current_balloon")
	if balloon and balloon.is_inside_tree():
		balloon.queue_free()
		DialogueManager.set_meta("current_balloon", null)
