extends Control

@onready var ui_root = get_node_or_null("PLAYERQUEST")

var title_label: RichTextLabel = null
var quest_label: RichTextLabel = null

func _ready():
	if ui_root == null:
		push_error("❌ PLAYERQUEST not found!")
		return

	# --------------------------------------------------
	# Title Label (Centered)
	# --------------------------------------------------
	if ui_root.has_node("Name"):
		title_label = ui_root.get_node("Name")
		if title_label is RichTextLabel:
			title_label.bbcode_enabled = true
			title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			title_label.text = "[center][b]Player Quest[/b][/center]"
		else:
			push_error("❌ 'Name' is NOT a RichTextLabel!")

	# --------------------------------------------------
	# Quest Label (Centered)
	# --------------------------------------------------
	if ui_root.has_node("Quest1/Tasks"):
		quest_label = ui_root.get_node("Quest1/Tasks")
		if quest_label is RichTextLabel:
			quest_label.bbcode_enabled = true
			quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD

			# Center alignment inside the label
			quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			quest_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

			# Initial text
			quest_label.text = "[center]" + Quest3Manager.get_quest_text() + "[/center]"
		else:
			push_error("❌ 'Tasks' is not a RichTextLabel!")
	else:
		push_error("❌ Quest1/Tasks not found!")

	# --------------------------------------------------
	# Connect quest update signal
	# --------------------------------------------------
	Quest3Manager.quest_changed.connect(_update_quest)


func _update_quest(new_text):
	if quest_label:
		quest_label.text = "[center]" + new_text + "[/center]"
