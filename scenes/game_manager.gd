extends Node

@onready var enemy3 = get_node_or_null("Enemy3")
var game_completed = false

func _ready():
	print("GameManager parent: ", get_parent().name)
	print("Looking for Enemy3...")

	if not enemy3:
		print("⚠️ Enemy3 not found with current path!")
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

func _process(_delta):
	if not game_completed and enemy3 and enemy3.is_defeated:
		complete_game()

func complete_game():
	game_completed = true
	print("🎉 GAME COMPLETED!")
	show_completion_popup()

func show_completion_popup():
	var popup = AcceptDialog.new()
	popup.dialog_text = "🎉 CONGRATULATIONS! 🎉\n\nYou have completed Dungeon 1!!"
	popup.title = "Victory!"
	popup.ok_button_text = "Awesome!"
	popup.process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().root.add_child(popup)
	popup.popup_centered()

	get_tree().paused = true

	popup.confirmed.connect(func():
		get_tree().paused = false
		popup.queue_free()
	)

	popup.close_requested.connect(func():
		get_tree().paused = false
		popup.queue_free()
	)
