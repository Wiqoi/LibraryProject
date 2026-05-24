extends RigidBody2D
		
var player_node: CharacterBody2D = null
@export var interaction_range: float = 100.0
@export var map_min: Vector2 = Vector2(-800, -800)
@export var map_max: Vector2 = Vector2(800, 800)
var is_organizing: bool = false
var animated_sprite: AnimatedSprite2D
var is_mouse_hovering = false
var organize_timer: Timer
var done = 0

func find_player() -> void:
	player_node = Global.player_node
		
func _ready() -> void:
	find_player()
		
	var area = $Area2D
	area.mouse_entered.connect(func(): is_mouse_hovering = true)
	area.mouse_exited.connect(func(): is_mouse_hovering = false)
	area.input_pickable = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(self.linear_velocity != Vector2(0,0)):
		await get_tree().create_timer(0.1).timeout
		self.linear_velocity -= Vector2(0.1,0.1)
		self.linear_velocity = Vector2(max(0, self.linear_velocity.x),max(0, self.linear_velocity.y))
	if is_organizing:
		return
	
	if player_node != null:
		var distance_to_player = global_position.distance_to(player_node.global_position)
		var is_near_player = distance_to_player <= interaction_range

		if is_near_player and is_mouse_hovering and Input.is_action_just_pressed("ui_interact") and done == 0:
			Picked_up()

func play_book_idle_animation() -> void:
	if animated_sprite.animation != "Idle":
		animated_sprite.play("Idle")

func Picked_up() -> void:
	self.visible = false
	self.position = Global.player_node.position
	Global.firstBackpack = 1
	Global.events_done += 1
	
