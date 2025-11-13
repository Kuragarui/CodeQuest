extends Node

# 🗺️ Quest progress tracking
var quests = {
	"talk_to_guide": false,
	"talk_to_master": false,
	"defeat_lord_printar": false,
	"defeat_number_warden": false,
	"defeat_keeper_of_decisions": false
}

# Order of quest progression
var quest_order = [
	"talk_to_guide",
	"talk_to_master",
	"defeat_lord_printar",
	"defeat_number_warden",
	"defeat_keeper_of_decisions"
]

# 🧭 Reference to the Quest UI controller
@onready var quest_ui: Node = get_node_or_null("/root/Game/CanvasLayer/Quests")

# 🧍‍♂️ References to key NPCs / nodes
var guide_npc: Node2D
var master_npc: Node2D
var enemy1_npc: Node2D
var player_ref: Node2D

# ⚙️ Scene-related state tracking
var scene_state = {
	"guide_active": true,
	"master_unlocked": false,
	"enemy_defeated": false,
	"final_scene": false
}

func _ready() -> void:
	print("✅ QuestManager loaded successfully")
	_reset_quests_if_all_done()
	_cache_npc_references()
	_show_current_quest()

# 🔁 Reset quests if previously all completed
func _reset_quests_if_all_done() -> void:
	var all_done := true
	for v in quests.values():
		if not v:
			all_done = false
			break
	if all_done:
		print("♻️ Resetting quest progress (all were completed)")
		for key in quests.keys():
			quests[key] = false

# 🧩 Cache important NPC nodes
func _cache_npc_references() -> void:
	guide_npc = get_node_or_null("/root/Game/Guide")
	master_npc = get_node_or_null("/root/Game/Master")
	enemy1_npc = get_node_or_null("/root/Game/Enemy1")
	player_ref = get_node_or_null("/root/Game/Player")

	if guide_npc: print("✅ Guide cached")
	if master_npc: print("✅ Master cached")
	if enemy1_npc: print("✅ Enemy1 cached")
	if player_ref: print("✅ Player cached")

# 🏁 Complete a quest and trigger updates
func complete_quest(quest_name: String) -> void:
	if quests.has(quest_name) and not quests[quest_name]:
		quests[quest_name] = true
		print("🏁 Quest completed:", quest_name)
		_apply_scene_changes(quest_name)
		_show_current_quest()
	else:
		print("⚠️ Quest not found or already completed:", quest_name)

# 🎬 Apply changes in the scene after certain quests
func _apply_scene_changes(quest_name: String) -> void:
	match quest_name:
		"talk_to_guide":
			print("🎬 Scene change: Guide dialogue complete")
			scene_state["guide_active"] = false
			scene_state["master_unlocked"] = true
			if guide_npc: _on_guide_dialogue_complete()

		"talk_to_master":
			print("🎬 Scene change: Master dialogue complete")
			scene_state["master_unlocked"] = false
			if master_npc: _on_master_dialogue_complete()

		"defeat_lord_printar":
			print("🎬 Scene change: Lord Printar defeated")
			scene_state["enemy_defeated"] = true
			scene_state["final_scene"] = false
			if enemy1_npc: _on_enemy_defeated()

		"defeat_number_warden":
			print("🎬 Scene change: Number Warden defeated")
			scene_state["final_scene"] = true

func _on_guide_dialogue_complete() -> void:
	print("📍 Guide interaction finished. Unlocking Guide Door...")

	# 🔓 Open any door that belongs to the "guide_door" group
	get_tree().call_group("guide_door", "open_door")

func _on_master_dialogue_complete() -> void:
	print("📍 Master interaction finished.")

func _on_enemy_defeated() -> void:
	if enemy1_npc:
		var tween = create_tween()
		tween.tween_property(enemy1_npc, "scale", Vector2(0.8, 0.8), 0.5)
		print("⚡ Enemy shrinking after defeat...")

# 🧭 Determine which phase to show
func _show_current_quest() -> void:
	var next_quest_index := -1
	for i in range(quest_order.size()):
		if not quests[quest_order[i]]:
			next_quest_index = i
			break

	print("📜 Quests =", quests)
	print("🧩 next_quest_index =", next_quest_index)

	if quest_ui and quest_ui.has_method("update_quests"):
		quest_ui.update_quests(quests, quest_order, next_quest_index)
	else:
		push_warning("⚠️ Quest UI not found or missing update_quests()")

# 🔍 Check completion status
func is_quest_complete(quest_name: String) -> bool:
	return quests.get(quest_name, false)

# 📦 Return copy of scene state
func get_scene_state() -> Dictionary:
	return scene_state.duplicate()
