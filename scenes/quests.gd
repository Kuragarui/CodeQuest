extends Control

@onready var ui_root: Node = get_node_or_null("PLAYERQUEST")
var single_task_label: RichTextLabel = null
var title_label: RichTextLabel = null

func _ready() -> void:
	print("🧭 Quests UI initializing...")

	if ui_root == null:
		push_error("❌ ui_root not found. Script expects PLAYERQUEST under Quests.")
		return

	# keep your header as "PLAYER QUEST"
	title_label = ui_root.get_node_or_null("Name") if ui_root.has_node("Name") else null
	if title_label and title_label is RichTextLabel:
		title_label.bbcode_enabled = true
		title_label.text = "[center][b]PLAYER QUEST[/b][/center]"

	# find the main task list label
	single_task_label = _find_tasks_in(ui_root)
	if single_task_label:
		single_task_label.bbcode_enabled = true
		single_task_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		print("✅ Found quest label:", single_task_label.name)
	else:
		push_error("❌ No RichTextLabel found under PLAYERQUEST!")

# find the Tasks label
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


# --- Update quests dynamically (same logic, centered, no phase header) ---
func update_quests(quests: Dictionary, quest_order: Array, next_quest_index: int) -> void:
	if single_task_label == null:
		return

	var keys: Array = []

	match next_quest_index:
		0, 1, 2:
			keys = ["talk_to_guide", "talk_to_master", "defeat_lord_printar"]
		3:
			keys = ["defeat_number_warden"]
		4:
			keys = ["defeat_keeper_of_decisions"]
		_:
			single_task_label.text = "[center]🎉 [b]All quests completed![/b][/center]"
			return

	# Centered tasks list only (no "Phase 1" header)
	var text := "[center]"
	for key in keys:
		var parts = key.replace("_", " ").split(" ")
		for i in range(parts.size()):
			parts[i] = parts[i].capitalize()
		var display := " ".join(parts)

		if quests.get(key, false):
			text += "[color=green]✔[/color] " + display + "\n"
		else:
			text += "[color=gray]•[/color] " + display + "\n"

	text += "[/center]"
	single_task_label.text = text.strip_edges()
