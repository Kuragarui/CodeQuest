extends Node

@onready var enemy3 = get_node_or_null("Enemy3")  # Changed from "../Enemy3" to "Enemy3"
var game_completed = false

func _ready():
	print("GameManager parent: ", get_parent().name)
	print("Looking for Enemy3...")
	
	if not enemy3:
		print("⚠️ Enemy3 not found with current path!")
		# Try to find it manually
		var parent = get_parent()
		for child in parent.get_children():
			if "enemy3" in child.name.to_lower():
				enemy3 = child
				print("✅ Found Enemy3: ", child.name)
				break
	
	if enemy3:
		print("✅ Game Manager ready - watching for game completion")
	else:
		print("⚠️ Could not find Enemy3 anywhere!")

func _process(delta):
	# Check if Enemy3 is defeated and game hasn't been completed yet
	if not game_completed and enemy3 and enemy3.is_defeated:
		complete_game()

func complete_game():
	game_completed = true
	print("🎉 GAME COMPLETED!")
	show_completion_popup()

func show_completion_popup():
	# Create a simple popup
	var popup = AcceptDialog.new()
	popup.dialog_text = "🎉 CONGRATULATIONS! 🎉\n\nYou have defeated all enemies!\nGame Complete!"
	popup.title = "Victory!"
	popup.ok_button_text = "Awesome!"
	
	# Make popup work even when game is paused
	popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Add popup to the scene
	get_tree().root.add_child(popup)
	popup.popup_centered()
	
	# Pause the game when popup shows
	get_tree().paused = true
	
	# When popup is closed (by clicking OK or X button), unpause the game
	popup.confirmed.connect(func():
		get_tree().paused = false
		popup.queue_free()
	)
	
	# Also handle when user closes with X button
	popup.close_requested.connect(func():
		get_tree().paused = false
		popup.queue_free()
	)
