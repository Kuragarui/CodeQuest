extends Node2D

const SPEED = 60
var direction = 1
var is_interacting = false
var is_defeated = false
var npc_name = "Number Warden"

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var quest_manager = QuestManager

var has_played_defeat_animation = false
var current_balloon = null

func _process(delta):
	if not is_interacting and not is_defeated:
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		elif ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false
		position.x += direction * SPEED * delta

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and not is_defeated:
		is_interacting = true
		show_dialog()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		is_interacting = false
		if current_balloon and current_balloon.is_inside_tree():
			current_balloon.queue_free()
			current_balloon = null
		print(npc_name + ": Farewell, adventurer!")

func show_dialog():
	var dialogue_resource = load("res://Dialogue/enemy2_dialogue.dialogue")
	DialogueManager.set_meta("current_enemy", self)
	current_balloon = DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")

func mark_defeated():
	if not is_defeated:
		is_defeated = true
		print(npc_name + " has been defeated!")
		quest_manager.complete_quest("defeat_number_warden")
		animated_sprite.modulate = Color(1, 1, 1, 0.5)
		set_process(false)
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
	print( npc_name + " defeated dramatically!")
	
