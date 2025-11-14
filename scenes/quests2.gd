extends Control

@onready var ui_root: Node = get_node_or_null("PLAYERQUEST")
var single_task_label: RichTextLabel = null
var title_label: RichTextLabel = null

func _ready() -> void:
	print("🧭 Quests UI initializing...")
	
	if ui_root == null:
		push_error("❌ ui_root not found. Script expects PLAYERQUEST under Quests.")
		return
	
	# Title header "PLAYER QUEST"
	title_label = ui_root.get_node_or_null("Name") if ui_root.has_node("Name") else null
	if title_label and title_label is RichTextLabel:
		title_label.bbcode_enabled = true
		title_label.text = "[center][b]PLAYER QUEST[/b][/center]"
	
	# Main task label
	single_task_label = _find_tasks_in(ui_root)
	if single_task_label:
		single_task_label.bbcode_enabled = true
		single_task_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		print("✅ Found quest task label:", single_task_label.name)
	else:
		push_error("❌ No RichTextLabel found under PLAYERQUEST!")


# Finds "Tasks" label
func _find_tasks_in(container: Node) -> RichTextLabel:
	if container == null:
		return null
	
	# First pass: look for a node named "Tasks"
	for child in container.get_children():
		if child is RichTextLabel and child.name.to_lower() == "tasks":
			return child
	
	# Second pass: check grandchildren named "Tasks"
	for child in container.get_children():
		if child is Node:
			for grand in child.get_children():
				if grand is RichTextLabel and grand.name.to_lower() == "tasks":
					return grand
	
	# Third pass: any RichTextLabel will do
	for child in container.get_children():
		if child is RichTextLabel:
			return child
	
	# Fourth pass: any grandchild RichTextLabel
	for child in container.get_children():
		if child is Node:
			for grand in child.get_children():
				if grand is RichTextLabel:
					return grand
	
	return null


# -----------------------------------------------------------------
#             UPDATED QUEST SYSTEM (DUNGEON ENEMIES)
# -----------------------------------------------------------------
func update_quests(quests: Dictionary, quest_order: Array, next_quest_index: int) -> void:
	if single_task_label == null:
		push_warning("⚠️ Cannot update quests: single_task_label is null")
		return
	
	var keys: Array = []
	
	match next_quest_index:
		0:  # First quest
			keys = ["defeat_malupiton"]
		1:  # Second quest
			keys = ["defeat_malupiton", "defeat_baklang_thomas"]
		2:  # Third quest
			keys = ["defeat_malupiton", "defeat_baklang_thomas", "defeat_wally_bayola"]
		-1:  # All quests finished
			single_task_label.text = "[center]➡ All enemies defeated!\nProceed to the next dungeon.[/center]"
			single_task_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			single_task_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			print("🎉 All quests completed - UI updated")
			return
	
	# Build centered quest list
	var text := "[center]"
	for key in keys:
		var readable: String = key.replace("_", " ").capitalize()
		if quests.get(key, false):
			text += "[color=green]✔[/color] " + readable + "\n"
		else:
			text += "[color=gray]•[/color] " + readable + "\n"
	text += "[/center]"
	
	single_task_label.text = text
	single_task_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	single_task_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	print("📝 Quest UI updated. Next quest index:", next_quest_index)
