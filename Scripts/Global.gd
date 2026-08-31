# Global.gd (Autoload Singleton)
extends Node

# Interaction progress signals (emitted by interactable objects, consumed by HUD)
signal interaction_started(action_text: String)
signal interaction_progress(ratio: float)
signal interaction_finished()
signal task_completed(world_pos: Vector2)

# ✅ Global variable to store the player node (accessible from any script)
# Type hint it as CharacterBody2D (match your player's node type)
var player_node: CharacterBody2D = null
var bookdropcoords = []
var studentspawnarea = []
var score = 0
var student_count = 0
var first_food = 0
var LR = 0
var UD = 0
var volume = 0
var hPage = 0
var lvl1done = 0
var lvl2done = 0
var lvl3done = 0
var givenText = ""
var showRules = 0
var firstS = 0
var firstBook = 0
var firstBackpack = 0
var firstFighting = 0
var firstNoise = 0
var firstRunning = 0
var firstChairs = 0
var firstCheckout = 0
var firstLineup = 0
var firstEnter = 0
var firstLeave = 0
var Objectives = ""
var events_done = 0
var events_total = 0
var player_has_backpack: bool = false
var player_has_book: bool = false
var is_interacting: bool = false

# Per-objective progress counters (Level 1)
var sanitize_done: int = 0
var sanitize_total: int = 10
var cubby_done: int = 0
var cubby_total: int = 5
var fighting_done: int = 0
var fighting_total: int = 1
var enter_done: int = 0
var enter_total: int = 1

# Per-objective progress counters (Level 2)
var books_done: int = 0
var books_total: int = 5
var shouting_done: int = 0
var shouting_total: int = 3
var running_done: int = 0
var running_total: int = 3
var food_done: int = 0
var food_total: int = 4
# Per-objective progress counters (Level 3)
var checkout_done: int = 0
var checkout_total: int = 0
var chairs_done: int = 0
var chairs_total: int = 0
var leave_done: int = 0
var leave_total: int = 0
var lineup_done: int = 0
var lineup_total: int = 0
# Indexed by line in the objectives text file; true = objective complete
var objectives_done: Array = [false, false, false, false]
# Indexed by line; true = objective visible to the player (its events are available)
var objectives_revealed: Array = [true, true, false, false]
# True during the end-of-level cutscene (blocks level auto-transition and movement)
var level_transitioning: bool = false
# Which rule reminders have already been shown (persists across levels)
var rules_shown: Dictionary = {}
