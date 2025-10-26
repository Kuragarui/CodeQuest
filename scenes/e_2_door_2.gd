extends Node2D

@onready var collision = $StaticBody2D/CollisionShape2D
@onready var player = get_node_or_null("../Player")
@onready var enemy1 = get_node_or_null("../Enemy1")

var door_locked = true

func _ready():
	if not player:
		print("⚠️ Player not found in scene!")
	else:
		print("Door 2 ready - leads to Enemy2 chamber.")
	
	if not enemy1:
		print("⚠️ Enemy1 not found in scene!")

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
	# Door 2 unlocks if ALL conditions are met:
	# 1. Talked to Guide
	# 2. Talked to Master
	# 3. Enemy1 is defeated
	if player.talked_to_guide and player.talked_to_master and enemy1 and enemy1.is_defeated:
		print("✅ Door 2 unlocked! All requirements met.")
		door_locked = false
	else:
		var missing = []
		if not player.talked_to_guide:
			missing.append("Talk to Guide")
		if not player.talked_to_master:
			missing.append("Talk to Master")
		if enemy1 and not enemy1.is_defeated:
			missing.append("Defeat Enemy1")
		
		print("🚫 Door 2 is locked! Requirements: " + str(missing))

func _open_door():
	# Disable the door's collider so the player can walk through
	if collision.disabled == false:
		collision.disabled = true
		print("🚪 Door 2 opened! Entering Enemy2's chamber...")
