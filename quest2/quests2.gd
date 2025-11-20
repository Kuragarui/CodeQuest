extends Control

@onready var ui_root = get_node_or_null("PLAYERQUEST")
var title_label: RichTextLabel = null
var single_task_label: RichTextLabel = null

func _ready():
	print("🧭 Quest UI initializing...")

	if ui_root == null:
		push_error("❌ PLAYERQUEST not found")
		return

	# Title
	if ui_root.has_node("Name"):
		title_label = ui_root.get_node("Name")
		if title_label is RichTextLabel:
			title_label.bbcode_enabled = true
			title_label.text = "[center][b]PLAYER QUEST[/b][/center]"

	# Task label
	single_task_label = _find_tasks_in(ui_root)

	if single_task_label:
		single_task_label.bbcode_enabled = true
		single_task_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	else:
		push_error("❌ No RichTextLabel found for quest tasks")


# ---------------------------------------------------------
# Find task label
# ---------------------------------------------------------
func _find_tasks_in(container: Node) -> RichTextLabel:
	if container == null:
		return null
	
	for c in container.get_children():
		if c is RichTextLabel and c.name.to_lower() == "tasks":
			return c
	
	for c in container.get_children():
		for g in c.get_children():
			if g is RichTextLabel and g.name.to_lower() == "tasks":
				return g
	
	for c in container.get_children():
		if c is RichTextLabel:
			return c
	
	for c in container.get_children():
		for g in c.get_children():
			if g is RichTextLabel:
				return g
	
	return null


# ---------------------------------------------------------
# UPDATE QUEST TEXT
# ---------------------------------------------------------
func update_quests(quests: Dictionary, order: Array, next_index: int):
	if single_task_label == null:
		return

	# Center text inside label
	single_task_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	single_task_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# All quests completed
	if next_index == -1:
		single_task_label.text = "[center]➡ All enemies defeated!\nProceed to the next dungeon.[/center]"
		return

	var keys := []

	match next_index:
		0:
			keys = ["Defeat_Scripter"]
		1:
			keys = ["Defeat_Scripter", "Defeat_Cipherer"]
		2:
			keys = ["Defeat_Scripter", "Defeat_Cipherer", "Defeat_Judger"]

	var text := "[center]"
	for key in keys:
		var readable = key.replace("_", " ").capitalize()

		if quests.get(key, false):
			text += "[color=green]✔[/color] " + readable + "\n"
		else:
			text += "[color=gray]•[/color] " + readable + "\n"

	text += "[/center]"

	single_task_label.text = text
