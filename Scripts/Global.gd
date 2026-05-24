# Global.gd (Autoload Singleton)
extends Node

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
var Objectives = ""
var lvl1dc = 0
