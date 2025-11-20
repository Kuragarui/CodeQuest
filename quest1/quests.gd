extends Control
@onready var ui_root: Node = get_node_or_null("PLAYERQUEST")
var single_task_label: RichTextLabel = null
var title_label: RichTextLabel = null

func _ready() -> void:
	print("🧭 Quests UI initializing...")
	if ui_root == null:
		push_error("❌ ui_root not found. Script expects PLAYERQUEST under Quests.")
		return
	
	# Set header title
	title_label = ui_root.get_node_or_null("Name") if ui_root.has_node("Name") else null
	if title_label and title_label is RichTextLabel:
		title_label.bbcode_enabled = true
		title_label.text = "[center][b]PLAYER QUEST[/b][/center]"
	
	# Find the task list label
	single_task_label = _find_tasks_in(ui_root)
	if single_task_label:
		single_task_label.bbcode_enabled = true
		single_task_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		single_task_label.scroll_active = false
		single_task_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		single_task_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		single_task_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		single_task_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		print("✅ Found quest label:", single_task_label.name)
	else:
		push_error("❌ No RichTextLabel found under PLAYERQUEST!")

func _find_tasks_in(container: Node) -> RichTextLabel:
	if container == null:
		return null
	
	for child in container.get_children():
		if child is RichTextLabel and child.name.to_lower() == "tasks":
			return child
	
	for child in container.get_children():
		if child is Node:
			for grand in child.get_children():
				if grand is RichTextLabel and grand.name.to_lower() == "tasks":
					return grand
	
	for child in container.get_children():
		if child is RichTextLabel:
			return child
	
	for child in container.get_children():
		if child is Node:
			for grand in child.get_children():
				if grand is RichTextLabel:
					return grand
	
	return null

### --------------------------------------------------------
###      UPDATE QUESTS — ONE QUEST AT A TIME (CLEAN STYLE)
### --------------------------------------------------------
func update_quests(quests: Dictionary, quest_order: Array, next_quest_index: int) -> void:
	print("🔍 UI update_quests called - next_quest_index:", next_quest_index)
	
	if single_task_label == null:
		push_error("❌ single_task_label is null!")
		return
	
	# ALL QUESTS COMPLETE (next_quest_index is -1 or >= size)
	if next_quest_index == -1 or next_quest_index >= quest_order.size():
		single_task_label.text = "[center]➡ All enemies defeated!\nProceed to the next dungeon.[/center]"
		print("✅ Showing completion message")
		return
	
	# Get current quest
	var key = quest_order[next_quest_index]
	print("  Current quest:", key)
	
	# Pretty formatting
	var parts = key.replace("_", " ").split(" ")
	for i in range(parts.size()):
		parts[i] = parts[i].capitalize()
	var display := " ".join(parts)
	
	# Display current quest - clean, no colors or symbols
	single_task_label.text = "[center]" + display + "[/center]"
	print("✅ Updated UI to show:", display)
