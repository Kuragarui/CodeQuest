extends Node2D

@onready var collision = $StaticBody2D/CollisionShape2D
@onready var player = get_node_or_null("../Player")
@onready var enemy2 = get_node_or_null("../Enemy2")

var door_locked = true
var last_check_result = false  # Track if we already printed the message

func _ready():
	if not player:
		print("⚠️ Player not found in scene!")
	else:
		print("Door 3 ready - leads to Enemy3 chamber.")
	
	if not enemy2:
		print("⚠️ Enemy2 not found in scene!")

func _process(delta):
	if player:
		# Check distance between player and door
		var distance = player.global_position.distance_to(global_position)
		# When the player is close enough to the door
		if distance < 50:  # adjust range depending on tile size
			if door_locked:
				_check_unlock_condition()
			else:
				_open_door()

func _check_unlock_condition():
	# Door 3 unlocks if Enemy2 is defeated
	var all_conditions_met = enemy2 and enemy2.is_defeated
	
	if all_conditions_met:
		if door_locked:  # Only print once when unlocking
			print("✅ Door 3 unlocked! Enemy2 has been defeated.")
		door_locked = false
	else:
		# Only print missing requirements if they changed
		if not last_check_result:
			print("🚫 Door 3 is locked! Defeat Enemy2 first.")
	
	last_check_result = all_conditions_met

func _open_door():
	# Disable the door's collider so the player can walk through
	if collision.disabled == false:
		collision.disabled = true
		print("🚪 Door 3 opened! Entering Enemy3's chamber...")
