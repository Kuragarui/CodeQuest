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
var quest_ui: Node = null

# 🧍‍♂️ References to key NPCs / nodes
var guide_npc: Node2D
var master_npc: Node2D
var enemy1_npc: Node2D  # Lord Printar
var enemy2_npc: Node2D  # Number Warden
var enemy3_npc: Node2D  # Keeper of Decisions
var player_ref: Node2D

# ⚙️ Scene-related state tracking
var scene_state = {
	"guide_active": true,
	"master_unlocked": false,
	"enemy1_defeated": false,
	"enemy2_defeated": false,
	"enemy3_defeated": false,
	"final_scene": false
}

var _initialized := false

func _ready() -> void:
	print("✅ QuestManager autoload ready (waiting for game scene)")

# 🎮 Call this from game.tscn when it's ready
func initialize_game_scene() -> void:
	# REMOVED: the early return that prevented re-initialization
	# Now we always reinitialize when the game scene loads
	
	print("🎮 Initializing QuestManager for game scene...")
	await get_tree().process_frame
	await get_tree().process_frame  # Double wait for safety
	
	# Clear stale references first
	_clear_references()
	
	_reset_quests_if_all_done()
	_cache_npc_references()
	_show_current_quest()
	
	_initialized = true
	print("✅ QuestManager initialization complete!")

# 🧹 Clear all node references (important for retry/reload)
func _clear_references() -> void:
	quest_ui = null
	guide_npc = null
	master_npc = null
	enemy1_npc = null
	enemy2_npc = null
	enemy3_npc = null
	player_ref = null
	print("🧹 Cleared stale node references")

# 🔄 Call this when player dies/retries to fully reset
func reset_for_retry() -> void:
	print("🔄 Resetting QuestManager for retry...")
	_initialized = false
	_clear_references()
	
	# Reset all quests to incomplete
	for key in quests.keys():
		quests[key] = false
	
	# Reset scene state
	scene_state = {
		"guide_active": true,
		"master_unlocked": false,
		"enemy1_defeated": false,
		"enemy2_defeated": false,
		"enemy3_defeated": false,
		"final_scene": false
	}
	print("✅ QuestManager reset complete")

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
	print("🔍 Searching for game nodes...")
	
	# Find Quest UI - try multiple methods
	quest_ui = get_tree().root.find_child("Quests", true, false)
	if quest_ui:
		print("✅ Quest UI found:", quest_ui.get_path())
	else:
		push_error("❌ Quest UI NOT FOUND!")
	
	# Find NPCs
	guide_npc = get_tree().root.find_child("Guide", true, false)
	master_npc = get_tree().root.find_child("Master", true, false)
	enemy1_npc = get_tree().root.find_child("Enemy1", true, false)
	enemy2_npc = get_tree().root.find_child("Enemy2", true, false)
	enemy3_npc = get_tree().root.find_child("Enemy3", true, false)
	player_ref = get_tree().root.find_child("Player", true, false)

	# Debug output
	print("📦 Guide:", guide_npc)
	print("📦 Master:", master_npc)
	print("📦 Enemy1:", enemy1_npc)
	print("📦 Enemy2:", enemy2_npc)
	print("📦 Enemy3:", enemy3_npc)
	print("📦 Player:", player_ref)

# 🏁 Complete a quest and trigger updates
func complete_quest(quest_name: String) -> void:
	print("🔍 complete_quest called:", quest_name)
	
	if not _initialized:
		push_warning("⚠️ QuestManager not initialized yet!")
		return
	
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
			if is_instance_valid(guide_npc): _on_guide_dialogue_complete()

		"talk_to_master":
			print("🎬 Scene change: Master dialogue complete")
			scene_state["master_unlocked"] = false
			if is_instance_valid(master_npc): _on_master_dialogue_complete()

		"defeat_lord_printar":
			print("🎬 Scene change: Lord Printar defeated")
			scene_state["enemy1_defeated"] = true
			if is_instance_valid(enemy1_npc): _on_enemy_defeated(enemy1_npc)

		"defeat_number_warden":
			print("🎬 Scene change: Number Warden defeated")
			scene_state["enemy2_defeated"] = true
			if is_instance_valid(enemy2_npc): _on_enemy_defeated(enemy2_npc)

		"defeat_keeper_of_decisions":
			print("🎬 Scene change: Keeper of Decisions defeated")
			scene_state["enemy3_defeated"] = true
			scene_state["final_scene"] = true
			if is_instance_valid(enemy3_npc): _on_enemy_defeated(enemy3_npc)

func _on_guide_dialogue_complete() -> void:
	print("📍 Guide interaction finished.")

func _on_master_dialogue_complete() -> void:
	print("📍 Master interaction finished.")

func _on_enemy_defeated(enemy: Node2D) -> void:
	if is_instance_valid(enemy):
		var tween = create_tween()
		tween.tween_property(enemy, "scale", Vector2(0.8, 0.8), 0.5)
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

	if quest_ui == null or not is_instance_valid(quest_ui):
		push_warning("⚠️ Quest UI is null or invalid!")
		return
	
	if quest_ui.has_method("update_quests"):
		print("✅ Calling update_quests()")
		quest_ui.update_quests(quests, quest_order, next_quest_index)
	else:
		push_error("❌ Quest UI missing update_quests() method!")

# 🔍 Check completion status
func is_quest_complete(quest_name: String) -> bool:
	return quests.get(quest_name, false)

# 📦 Return copy of scene state
func get_scene_state() -> Dictionary:
	return scene_state.duplicate()
