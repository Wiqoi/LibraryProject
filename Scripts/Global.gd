# Global.gd (Autoload Singleton)
extends Node

# ✅ Global variable to store the player node (accessible from any script)
# Type hint it as CharacterBody2D (match your player's node type)
var player_node: CharacterBody2D = null
var bookdropcoords = []
var studentspawnarea = []
var score = 0
var student_count = 0
