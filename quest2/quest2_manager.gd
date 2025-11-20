extends Node

# Quest states
var quests = {
	"Defeat_Scripter": false,
	"Defeat_Cipherer": false,
	"Defeat_Judger": false,
}

# Display order
var quest_order = [
	"Defeat_Scripter",
	"Defeat_Cipherer",
	"Defeat_Judger"
]

# References
var quest_ui: Node = null
var enemy1_npc: Node2D = null
var enemy2_npc: Node2D = null
var enemy3_npc: Node2D = null
var player_ref: Node2D = null

var _initialized := false

func _ready() -> void:
	print("✅ Quest2Manager autoload ready (waiting for dungeon 2 scene)")

# Call this from second_dungeon.tscn when it loads
func initialize_dungeon2_scene() -> void:
	if _initialized:
		print("⚠️ Quest2Manager already initialized")
		return
	
	print("🎮 Initializing Quest2Manager for dungeon 2...")
	await get_tree().process_frame
	await get_tree().process_frame
	
	_reset_if_finished()
	_cache_ui()
	_cache_enemies()
	_connect_signals()
	_show_current()
	
	_initialized = true
	print("✅ Quest2Manager initialization complete!")

# ---------------------------------------------------------
# QUEST UI LOOKUP
# ---------------------------------------------------------
func _cache_ui():
	print("🔍 Searching for Quest UI in dungeon 2...")
	
	# Use find_child for more reliable searching
	quest_ui = get_tree().root.find_child("Quests", true, false)
	
	if quest_ui:
		print("✅ Quest UI found:", quest_ui.get_path())
	else:
		push_error("❌ Quest UI not found in dungeon 2!")

# ---------------------------------------------------------
func _reset_if_finished():
	var done := true
	for val in quests.values():
		if not val:
			done = false
			break
	
	if done:
		for k in quests.keys():
			quests[k] = false
		print("♻️ Reset dungeon 2 quest progress")

# ---------------------------------------------------------
# ENEMY LOOKUP
# ---------------------------------------------------------
func _cache_enemies():
	print("🔍 Searching for enemies in dungeon 2...")
	
	enemy1_npc = get_tree().root.find_child("enemy_1_D2", true, false)
	enemy2_npc = get_tree().root.find_child("enemy_2_D3", true, false)
	enemy3_npc = get_tree().root.find_child("enemy_3_D2", true, false)
	player_ref = get_tree().root.find_child("Player", true, false)
	
	print("📦 Enemy1 (Scripter):", enemy1_npc)
	print("📦 Enemy2 (Cipherer):", enemy2_npc)
	print("📦 Enemy3 (Judger):", enemy3_npc)
	print("📦 Player:", player_ref)

# ---------------------------------------------------------
# SIGNAL CONNECTION
# ---------------------------------------------------------
func _connect_signals():
	if enemy1_npc and enemy1_npc.has_signal("defeated"):
		enemy1_npc.defeated.connect(_on_enemy1_defeated)
		print("✅ Connected to Scripter defeat signal")
		
	if enemy2_npc and enemy2_npc.has_signal("defeated"):
		enemy2_npc.defeated.connect(_on_enemy2_defeated)
		print("✅ Connected to Cipherer defeat signal")
		
	if enemy3_npc and enemy3_npc.has_signal("defeated"):
		enemy3_npc.defeated.connect(_on_enemy3_defeated)
		print("✅ Connected to Judger defeat signal")

# ---------------------------------------------------------
# SIGNAL HANDLERS
# ---------------------------------------------------------
func _on_enemy1_defeated():
	print("⚔️ Scripter defeated")
	complete_quest("Defeat_Scripter")

func _on_enemy2_defeated():
	print("⚔️ Cipherer defeated")
	complete_quest("Defeat_Cipherer")

func _on_enemy3_defeated():
	print("⚔️ Judger defeated")
	complete_quest("Defeat_Judger")

# ---------------------------------------------------------
# COMPLETE QUEST
# ---------------------------------------------------------
func complete_quest(name: String):
	if not _initialized:
		push_warning("⚠️ Quest2Manager not initialized yet!")
		return
	
	if quests.has(name) and not quests[name]:
		quests[name] = true
		print("🏁 Completed:", name)
		_show_current()
	else:
		print("⚠️ Quest already completed or invalid:", name)

# ---------------------------------------------------------
# UPDATE QUEST UI
# ---------------------------------------------------------
func _show_current():
	if not quest_ui:
		push_warning("⚠️ Quest UI is null!")
		return
	
	if not quest_ui.has_method("update_quests"):
		push_error("❌ Quest UI missing update_quests() method!")
		return
	
	var next_index := -1
	for i in range(quest_order.size()):
		if not quests[quest_order[i]]:
			next_index = i
			break
	
	print("📜 Dungeon 2 Quests:", quests)
	print("🧩 next_quest_index:", next_index)
	
	quest_ui.update_quests(quests, quest_order, next_index)
