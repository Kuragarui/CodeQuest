extends Node2D

@onready var collision = $StaticBody2D/CollisionShape2D
@onready var player = get_node_or_null("../Player")

var door_locked = true

func _ready():
	if not player:
		print("⚠️ Player not found in scene!")
	else:
		print("Door 1 ready - leads to Enemy1 chamber.")

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
	# Door 1 unlocks after talking to both Guide and Master
	if player.talked_to_guide and player.talked_to_master:
		print("✅ Door 1 unlocked! You may enter Enemy1's chamber.")
		door_locked = false
	else:
		var missing = []
		if not player.talked_to_guide:
			missing.append("Guide")
		if not player.talked_to_master:
			missing.append("Master")
		
		print("🚫 Door 1 is locked! Talk to: " + str(missing))

func _open_door():
	# Disable the door's collider so the player can walk through
	if collision.disabled == false:
		collision.disabled = true
		print("🚪 Door 1 opened! Entering Enemy1's chamber...")
