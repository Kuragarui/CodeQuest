extends Node2D

const SPEED = 60
var direction = 1
var is_interacting = false
var is_defeated = false  # Track if enemy is defeated
var npc_name = "Number Warden"

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	# Only move if not interacting and not defeated
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
		if not is_defeated:
			print(npc_name + " watches you leave...")

func show_dialog():
	var dialogue_resource = load("res://Dialogue/enemy2_dialogue.dialogue")
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
