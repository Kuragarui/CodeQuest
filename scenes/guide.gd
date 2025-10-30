extends Node2D

signal talked_to

var is_interacting = false
var has_talked = false
var npc_name = "Guider Elden"

@onready var animated_sprite = $AnimatedSprite2D
@onready var interact_area = $Area2D
@onready var quest_manager = QuestManager

# 🟢 NEW: Track if scene change has occurred
var post_dialogue_scene_changed = false

func _ready():
	interact_area.body_entered.connect(_on_Area2D_body_entered)
	interact_area.body_exited.connect(_on_Area2D_body_exited)
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
	var balloon = DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")
	DialogueManager.set_meta("current_balloon", balloon)

func _on_dialogue_finished(resource):
	if resource.resource_path == "res://Dialogue/guider_dialogue.dialogue":
		is_interacting = false
		if not has_talked:
			has_talked = true
			emit_signal("talked_to")
			print("✅ " + npc_name + " talked_to signal emitted!")
			
			# 🟢 Update quest tracker
			if quest_manager:
				quest_manager.complete_quest("talk_to_guide")
			
			# 🟢 NEW: Apply scene changes after dialogue
			if not post_dialogue_scene_changed:
				_apply_post_dialogue_scene_change()
		close_dialog()

# 🟢 NEW: Scene changes after Guide dialogue
func _apply_post_dialogue_scene_change():
	post_dialogue_scene_changed = true
	
	print("🎬 Guide scene change applied")

func close_dialog():
	var balloon = DialogueManager.get_meta("current_balloon")
	if balloon and balloon.is_inside_tree():
		balloon.queue_free()
		DialogueManager.set_meta("current_balloon", null)
