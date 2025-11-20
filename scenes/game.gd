extends Node2D  # Change to Node if your root is a Node, not Node2D

func _ready() -> void:
	print("🎮 game.tscn loaded - initializing QuestManager")
	
	# Wait for all child nodes to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Initialize QuestManager now that game scene is loaded
	if QuestManager:
		QuestManager.initialize_game_scene()
	else:
		push_error("❌ QuestManager autoload not found!")
