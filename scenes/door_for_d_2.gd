extends Node2D

@onready var collision = $StaticBody2D/CollisionShape2D
@onready var player = get_node_or_null("../Player")
@onready var enemy3 = get_node_or_null("../Enemy3")

var door_locked = true
var last_check_result = false  # Track if we already printed the message

func _ready():
	if not player:
		print("⚠️ Player not found in scene!")
	else:
		print("Door 4 ready — leads to the next area after Enemy3.")
	
	if not enemy3:
		print("⚠️ Enemy3 not found in scene!")

func _process(delta):
	if player:
		# Check distance between player and door
		var distance = player.global_position.distance_to(global_position)
		
		# When player is close enough to the door
		if distance < 50:  # adjust this distance depending on map scale
			if door_locked:
				_check_unlock_condition()
			else:
				_open_door()

func _check_unlock_condition():
	# Door 4 unlocks if Enemy3 is defeated
	var all_conditions_met = enemy3 and enemy3.is_defeated
	
	if all_conditions_met:
		if door_locked:
			print("✅ Door 4 unlocked! Enemy3 has been defeated.")
		door_locked = false
	else:
		if not last_check_result:
			print("🚫 Door 4 is locked! Defeat Enemy3 first.")
	
	last_check_result = all_conditions_met

func _open_door():
	# Disable collider so player can walk through
	if collision.disabled == false:
		collision.disabled = true
		print("🚪 Door 4 opened! Proceeding to the next area...")
