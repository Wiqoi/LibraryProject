extends CharacterBody2D

var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
var is_pushing: bool = false
var animated_sprite: AnimatedSprite2D
var is_mouse_hovering = false
var chair_timer: Timer

func find_player() -> void:
	player_node = Global.player_node

func _ready() -> void:
	find_player()
	
	animated_sprite = $AnimatedSprite2D
	
	chair_timer = Timer.new()
	add_child(chair_timer)
	chair_timer.wait_time = 55.0
	chair_timer.one_shot = true
	chair_timer.timeout.connect(_on_timer_timeout)
	chair_timer.start()
	
	var area = $Area2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true
	
	if animated_sprite:
		animated_sprite.play("BookIdle")
		animated_sprite.animation_finished.connect(_on_animation_finished)

func push_chair_animation() -> void:
	if not is_pushing and animated_sprite.animation != "BookOrganize":
		is_pushing = true
		animated_sprite.stop()
		animated_sprite.play("BookOrganize")
		
		var time_remaining = chair_timer.time_left
		var time_score = int(time_remaining)
		Global.score += 1 + time_score
		if Global.score < 0:
			Global.score = 0

func _process(_delta: float) -> void:
	if is_pushing:
		return
	
	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and Input.is_action_just_pressed("ui_interact"):
			push_chair_animation()

func _on_timer_timeout() -> void:
	Global.score -= 55
	if Global.score < 0:
		Global.score = 0
	queue_free()

func _on_animation_finished() -> void:
	var anim_name = animated_sprite.animation
	Global.first_food = 1
	if anim_name == "BookOrganize":
		queue_free()
