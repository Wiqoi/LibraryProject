extends CharacterBody2D

var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
@export var map_min: Vector2 = Vector2(-800, -800)
@export var map_max: Vector2 = Vector2(800, 800)
var is_organizing: bool = false
var animated_sprite: AnimatedSprite2D
var is_mouse_hovering = false
var organize_timer: Timer

func find_player() -> void:
	player_node = Global.player_node
		
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	find_player()
	
	animated_sprite = $AnimatedSprite2D
	
	organize_timer = Timer.new()
	add_child(organize_timer)
	organize_timer.wait_time = 25.0
	organize_timer.one_shot = true
	organize_timer.timeout.connect(_on_timer_timeout)
	organize_timer.start()
	
	var area = $Area2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true
	
	randomize_spawn_position()
	
	if animated_sprite:
		play_book_idle_animation()
		animated_sprite.animation_finished.connect(_on_animation_finished)

func randomize_spawn_position() -> void:
	if Global.bookdropcoords.size() > 0:
		global_position = Global.bookdropcoords.pick_random()
	print(global_position)
	if global_position in Global.bookdropcoords:
		print("yay")

func play_book_idle_animation() -> void:
	if animated_sprite.animation != "BookIdle":
		animated_sprite.play("BookIdle")

func play_book_organize_animation() -> void:
	if not is_organizing and animated_sprite.animation != "BookOrganize":
		is_organizing = true
		animated_sprite.stop()
		animated_sprite.play("BookOrganize")
		
		var time_remaining = organize_timer.time_left
		var time_score = int(time_remaining)
		Global.score += 1 + time_score
		if Global.score < 0:
			Global.score = 0
		print("Book organized! Time bonus: ", time_score, " seconds")

func _process(_delta: float) -> void:
	if is_organizing:
		return
	
	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and Input.is_action_just_pressed("ui_interact"):
			play_book_organize_animation()

func _on_timer_timeout() -> void:
	Global.score -= 25
	if Global.score < 0:
		Global.score = 0
	queue_free()

func _on_animation_finished() -> void:
	var anim_name = animated_sprite.animation
	if anim_name == "BookOrganize":
		queue_free()
