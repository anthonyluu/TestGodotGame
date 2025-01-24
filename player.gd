extends Area2D
signal hit

@export var speed = 400
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


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
	
	if direction.length() > 0:
		direction = direction.normalized()
	else:
		direction = velocity.normalized()
	
	print(direction)
	
	$AnimatedSprite2D.animation = "up"
	
	# make a vector that's current pos + direction
	# then look at that direction
	var direction_target = self.position + direction
	self.look_at(direction_target)



func _on_body_entered(body: Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
