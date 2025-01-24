class_name Player

extends Area2D
signal hit

@export var speed = 400

var screen_size
var direction_target
var bullet_path = preload("res://bullet.tscn")
var can_shoot: bool
var is_dead: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	direction_target = Vector2(1,0)
	can_shoot = true
	hide()

func start(pos):
	position = pos
	can_shoot = true
	show()
	$CollisionShape2D.disabled = false
	is_dead = false
	
func game_over():
	is_dead = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Look direction should depend on look controls
	var direction = Vector2.ZERO
	if Input.is_action_pressed("look_right"):
		direction.x += 1
	if Input.is_action_pressed("look_left"):
		direction.x -= 1
	if Input.is_action_pressed("look_up"):
		direction.y -= 1
	if Input.is_action_pressed("look_down"):
		direction.y += 1
	
	# Direction input has priority over velocity. If there's no direction input, then the rotation
	# will be based on the velocity
	if direction.length() > 0:
		direction = direction.normalized()
	else:
		direction = velocity.normalized()
	
	$AnimatedSprite2D.animation = "up"
	
	# make a vector that's current pos + direction
	# then look at that direction
	direction_target = self.position + direction
	self.look_at(direction_target)
	
	if Input.is_action_pressed("fire"):
		on_fire(direction_target)

func on_fire(spawn_point: Vector2):
	if is_dead:
		return
	if can_shoot:
		can_shoot = false
		# need to create the instance of the bullet in the direction
		var bullet = bullet_path.instantiate()
		bullet.dir = rotation
		bullet.pos = spawn_point
		bullet.rota = global_rotation
		get_parent().add_child(bullet)
		
		# set a timer to set can_shoot to true
		$BulletTimer.timeout.connect(set.bind("can_shoot", true))
		$BulletTimer.start()

func _on_body_entered(body: Node2D) -> void:
	# only take damage from mobs
	if body is Mob:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)
