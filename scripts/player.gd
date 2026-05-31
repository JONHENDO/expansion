extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var is_dead = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var collision_standing: CollisionShape2D = $CollisionStanding
@onready var ray_cast_attack: RayCast2D = $RayCastAttack



func _ready() -> void:
	add_to_group("Player")

func die():
	print("die() called")
	is_dead = true
	collision_crouch.set_deferred("disabled", true)
	collision_standing.set_deferred("disabled", true)
	
func respawn():
	is_dead = false
	collision_standing.set_deferred("disabled", false)
	collision_crouch.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	
	if !Global.room_pause:
		
	
		if is_dead:
			velocity += get_gravity() * delta
			move_and_slide()
			return
		
		#crouch controls
		if Input.is_action_pressed("crouch"):
			collision_crouch.disabled = false
			collision_standing.disabled = true
		else:
			collision_crouch.disabled = true
			collision_standing.disabled = false
		
		
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			

		#get movement direction (1, 0, -1)
		var direction := Input.get_axis("move_left", "move_right")
		
		#flip sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
			
		#play animations
		if animated_sprite.animation == "attack" and animated_sprite.is_playing():
			pass
			
		elif not is_on_floor():
			animated_sprite.play("jump")
		elif direction !=0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")	

		
		#applies movememt
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

		
		#attack
		if Input.is_action_just_pressed("attack"):
			print("attack pressed")
			animated_sprite.play("attack")

			if ray_cast_attack.is_colliding():
				var hit =ray_cast_attack.get_collider()
				print("attack hit", hit.name)
				if hit.is_in_group("Enemy"):
					hit.queue_free()
		
			
		
		

		move_and_slide()


#camera and room detection

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2
	
	Global.change_room(collision_shape.global_position, size)
