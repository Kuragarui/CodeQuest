extends Node2D

const SPEED = 60
var direction = 1
var is_interacting = false
var is_defeated = false
var npc_name = "Keeper of Decisions"

@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D
@onready var quest_manager = QuestManager

var has_played_defeat_animation = false

func _process(delta):
	# Only move if not interacting and not defeated
	if not is_interacting and not is_defeated:
		# Reverse direction when hitting top or bottom walls
		if ray_cast_down.is_colliding():
			direction = -1
			animated_sprite.flip_v = true
		elif ray_cast_up.is_colliding():
			direction = 1
			animated_sprite.flip_v = false
		
		# Move vertically
		position.y += direction * SPEED * delta

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and not is_defeated:
		is_interacting = true
		show_dialog()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		is_interacting = false
		if not is_defeated:
			print(npc_name + " watches you leave...")

func show_dialog():
	var dialogue_resource = load("res://Dialogue/enemy3_dialogue.dialogue")
	DialogueManager.set_meta("current_enemy", self)
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")

# Called when the player defeats or answers this NPC
func mark_defeated():
	if not is_defeated:
		is_defeated = true
		print(npc_name + " has been defeated!")

		# Complete the quest stage
		quest_manager.complete_quest("defeat_keeper_of_decisions")

		# Visual feedback
		animated_sprite.modulate = Color(1, 1, 1, 0.5)

		# Stop movement
		set_process(false)

		# Optional: dramatic defeat animation
		if not has_played_defeat_animation:
			_play_defeat_scene_change()

func _play_defeat_scene_change():
	has_played_defeat_animation = true

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(self, "modulate", Color.RED, 0.3)
	await tween.finished

	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(self, "position:y", position.y + 50, 1.0)
	tween2.tween_property(self, "modulate:a", 0.0, 1.0)
	tween2.tween_property(self, "scale", Vector2(0.5, 0.5), 1.0)

	print("💀 " + npc_name + " defeated dramatically!")
