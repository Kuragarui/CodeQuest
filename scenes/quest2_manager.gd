extends Node

# 🗺️ Quest progress tracking
var quests = {
	"defeat_malupiton": false,
	"defeat_baklang_thomas": false,
	"defeat_wally_bayola": false,
}

# Order of quest progression
var quest_order = [
	"defeat_malupiton",
	"defeat_baklang_thomas",
	"defeat_wally_bayola"
]

# 🧭 Reference to the Quest UI controller
var quest_ui: Node = null

# 🧍‍♂️ References to NPCs / Enemies
var enemy1_npc: Node2D = null  # Malupiton
var enemy2_npc: Node2D = null  # Baklang Thomas
var enemy3_npc: Node2D = null  # Wally Bayola
var player_ref: Node2D = null

# ⚙️ Scene-related state tracking
var scene_state = {
	"enemy_defeated": false,
	"final_scene": false
}

func _ready() -> void:
	print("✅ QuestManager loaded successfully")
	_reset_quests_if_all_done()
	# Delay to ensure nodes are ready
	call_deferred("_initialize_references")


func _initialize_references() -> void:
	_cache_quest_ui()
	_cache_enemy_references()
	_connect_enemy_signals()
	_show_current_quest()


# ---------------------------------------------------------
# CACHE QUEST UI
# ---------------------------------------------------------
func _cache_quest_ui() -> void:
	# Try to find Quest UI in current scene
	var root = get_tree().current_scene
	
	# Try multiple possible paths
	var possible_paths = [
		"CanvasLayer/Quests",
		"UI/Quests",
		"Quests",
		"HUD/Quests"
	]
	
	for path in possible_paths:
		quest_ui = root.get_node_or_null(path)
		if quest_ui:
			print("✅ Quest UI found at:", path)
			return
	
	# Try absolute paths as fallback
	var absolute_paths = [
		"/root/Game/CanvasLayer/Quests",
		"/root/Game/Quests"
	]
	
	for path in absolute_paths:
		quest_ui = get_node_or_null(path)
		if quest_ui:
			print("✅ Quest UI found at:", path)
			return
	
	push_warning("⚠️ Quest UI not found!")
	print("🔍 Scene root children:")
	if root:
		for child in root.get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
			if child.get_child_count() > 0:
				for grandchild in child.get_children():
					print("    - ", grandchild.name, " (", grandchild.get_class(), ")")


# ---------------------------------------------------------
# RESET IF ALL QUESTS COMPLETE
# ---------------------------------------------------------
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


# ---------------------------------------------------------
# CACHE REFERENCES
# ---------------------------------------------------------
func _cache_enemy_references() -> void:
	# Try to find enemies in current scene
	var root = get_tree().current_scene
	
	enemy1_npc = root.get_node_or_null("enemy_1_D2")
	if not enemy1_npc:
		enemy1_npc = get_node_or_null("/root/Game/enemy_1_D2")
	
	enemy2_npc = root.get_node_or_null("enemy_2_D3")
	if not enemy2_npc:
		enemy2_npc = get_node_or_null("/root/Game/enemy_2_D3")
	
	enemy3_npc = root.get_node_or_null("enemy_3_D2")
	if not enemy3_npc:
		enemy3_npc = get_node_or_null("/root/Game/enemy_3_D2")
	
	player_ref = root.get_node_or_null("Player")
	if not player_ref:
		player_ref = get_node_or_null("/root/Game/Player")

	if enemy1_npc: 
		print("✅ Enemy1 cached (Malupiton)")
	else:
		push_warning("⚠️ Enemy1 (Malupiton) not found")
		
	if enemy2_npc: 
		print("✅ Enemy2 cached (Baklang Thomas)")
	else:
		push_warning("⚠️ Enemy2 (Baklang Thomas) not found")
		
	if enemy3_npc: 
		print("✅ Enemy3 cached (Wally Bayola)")
	else:
		push_warning("⚠️ Enemy3 (Wally Bayola) not found")
		
	if player_ref: 
		print("✅ Player cached")


# ---------------------------------------------------------
# CONNECT ENEMY SIGNALS
# ---------------------------------------------------------
func _connect_enemy_signals() -> void:
	if enemy1_npc and enemy1_npc.has_signal("defeated"):
		if not enemy1_npc.is_connected("defeated", _on_enemy1_defeated):
			enemy1_npc.connect("defeated", _on_enemy1_defeated)
			print("🔗 Connected Malupiton defeated signal")
	else:
		push_warning("⚠️ Cannot connect Malupiton signal")

	if enemy2_npc and enemy2_npc.has_signal("defeated"):
		if not enemy2_npc.is_connected("defeated", _on_enemy2_defeated):
			enemy2_npc.connect("defeated", _on_enemy2_defeated)
			print("🔗 Connected Baklang Thomas defeated signal")
	else:
		push_warning("⚠️ Cannot connect Baklang Thomas signal")

	if enemy3_npc and enemy3_npc.has_signal("defeated"):
		if not enemy3_npc.is_connected("defeated", _on_enemy3_defeated):
			enemy3_npc.connect("defeated", _on_enemy3_defeated)
			print("🔗 Connected Wally Bayola defeated signal")
	else:
		push_warning("⚠️ Cannot connect Wally Bayola signal")


# ---------------------------------------------------------
# SIGNAL HANDLERS
# ---------------------------------------------------------
func _on_enemy1_defeated():
	print("⚔️ Malupiton defeated!")
	print("🔍 Quest UI reference:", quest_ui)
	complete_quest("defeat_malupiton")

func _on_enemy2_defeated():
	print("⚔️ Baklang Thomas defeated!")
	complete_quest("defeat_baklang_thomas")

func _on_enemy3_defeated():
	print("⚔️ Wally Bayola defeated!")
	print("🔍 Quest UI reference:", quest_ui)
	print("🔍 Current quests state:", quests)
	complete_quest("defeat_wally_bayola")
	print("🔍 After complete - quests state:", quests)


# ---------------------------------------------------------
# COMPLETE QUEST
# ---------------------------------------------------------
func complete_quest(quest_name: String) -> void:
	if quests.has(quest_name) and not quests[quest_name]:
		quests[quest_name] = true
		print("🏁 Quest completed:", quest_name)
		_show_current_quest()
	else:
		print("⚠️ Quest not found or already completed:", quest_name)


# ---------------------------------------------------------
# UPDATE QUEST UI
# ---------------------------------------------------------
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


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
func is_quest_complete(quest_name: String) -> bool:
	return quests.get(quest_name, false)

func get_scene_state() -> Dictionary:
	return scene_state.duplicate()

func are_all_quests_complete() -> bool:
	for v in quests.values():
		if not v:
			return false
	return true
