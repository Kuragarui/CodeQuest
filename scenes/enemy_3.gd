extends Node2D

const SPEED = 60
var direction = 1
var is_interacting = false
var is_defeated = false  # Track if enemy is defeated
var npc_name = "Keeper of Decisions"

@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	# Only move if not interacting and not defeated
	if not is_interacting and not is_defeated:
		# Reverse direction when hitting top or bottom walls
		if ray_cast_down.is_colliding():
			direction = -1
		elif ray_cast_up.is_colliding():
			direction = 1
		
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
	# Store reference to self in DialogueManager so dialogue can access it
	DialogueManager.set_meta("current_enemy", self)
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")

# Call this function when the player answers correctly
func mark_defeated():
	if not is_defeated:
		is_defeated = true
		print(npc_name + " has been defeated!")
		
		# Optional: Visual feedback (make enemy transparent or hide)
		animated_sprite.modulate = Color(1, 1, 1, 0.5)
		
		# Stop moving permanently
		set_process(false)
