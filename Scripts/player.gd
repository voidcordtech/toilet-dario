extends CharacterBody3D
class_name Player

@onready var camera_pivot: Node3D = $CameraPivot
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var pointing_ray: RayCast3D = $CameraPivot/SpringArm3D/Camera3D/PointingRay
@onready var mario: Node3D = $mario
@onready var gun_holder: Node3D = $GunHolder
@onready var camera_3d: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var body_marker: Marker3D = $Marker/BodyMarker
@onready var head_ray: RayCast3D = $Marker/HeadMarker/HeadRay
@onready var score_marker: Marker3D = $Marker/ScoreMarker
@onready var gun_reload_cd: Timer = $GunReloadCd


''' Health '''
@export_group('Health Component')
@export var health_component: HealthComponent

''' Movement '''
@export_group('Movement')
@export var speed: float = 3
@export var jump_velocity: float = 6
@export var gravity = Vector3(0, -12, 0)
@export var knock_velocity := Vector3.ZERO
@export var knock_friction := 100
var can_input := true


''' Camera '''
@export_group('Camera')
@export var mouse_sensitivity: float = 0.001
@export var up_rotate_limit: float = -80.0
@export var down_rotate_limit: float = 80.0

''' Shoot '''
var is_reloading = false
var is_shooting = false
var can_shoot = false
var current_gun: Gun

''' Raycast '''
var pointing_target: Node3D

''' Teleport '''
var is_teleporting = false

''' Hurt '''
var flash_tween: Tween




func _ready() -> void:
	LevelManager.player_ready.emit(self)
	
	health_component.dead.connect(die)
	health_component.health_changed.connect(hurt)
	gun_reload_cd.timeout.connect(reloaded)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	
	if can_input:
		if Input.is_action_pressed("jump") and is_on_floor():
			jump(jump_velocity)
		
		handle_move(delta)
		handle_animation()
		handle_ray_cast()
		check_head_brick()
		
		if is_shooting:
			shooting()
		
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if can_input:
		handle_camera_motion_input(event)
		handle_shoot(event)



func jump(value: float = jump_velocity):
	velocity.y = value

func stop_input():
	can_input = false

func restore_input():
	can_input = true







''' Pointing '''
func handle_ray_cast():
	pointing_target = pointing_ray.get_collider()



''' Shoot '''
func handle_shoot(event: InputEvent):
	current_gun = get_current_gun()
	
	if !current_gun:
		return
	
	if event.is_action_pressed('shoot') and !is_reloading:
		is_shooting = true
		current_gun.show()
		
	if event.is_action_released('shoot') and !is_reloading:
		is_shooting = false
		current_gun.hide()
	
	if event.is_action_pressed('reload'):
		reload()

func shooting():
	
	if !can_shoot:
		return
	
	# Get direction
	var destination: Vector3 = pointing_ray.to_global(pointing_ray.target_position)
	var direction: Vector3 = (destination - gun_holder.global_position).normalized()
	
	# Damage Enemy
	if pointing_target is Enemy:
		pointing_target.health_component.take_damage(current_gun.stats.damage)
		VfxManager.add_vfx(VfxManager.enemy_hurt_vfx, pointing_ray.get_collision_point())
	
	# Add bullet
	current_gun.shoot_bullet(direction)
	
	# Play sfx
	SfxManager.rifle_shoot_sfx.play()
	
	# Ammo
	current_gun.current_ammo -= 1
	if current_gun.current_ammo <= 0:
		reload()
		return
	
	
	# CD
	can_shoot = false
	await get_tree().create_timer(current_gun.stats.cd).timeout
	can_shoot = true

func get_current_gun() -> Gun:
	return gun_holder.get_child(0)

func reload():
	
	if is_reloading or current_gun.current_ammo == current_gun.stats.ammo:
		return
	
	# Start
	can_shoot = false
	is_shooting = false
	is_reloading = true
	SfxManager.gun_re_sfx.play()
	
	gun_reload_cd.start(current_gun.stats.reload_duration)

func reloaded():
	# Done
	can_shoot = true
	is_reloading = false
	current_gun.current_ammo = current_gun.stats.ammo
	SfxManager.gun_reload_sfx.play()




''' Movement '''
func handle_move(delta: float):
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	velocity += knock_velocity

	# Decay the knockback
	knock_velocity = knock_velocity.move_toward(Vector3.ZERO, knock_friction * delta)

func apply_knock(force: Vector3):
	knock_velocity = force

func handle_gravity(delta:float):
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta





''' Animation '''
func handle_animation():
	animation_tree.set('parameters/conditions/idle', is_on_floor() and !velocity and !is_shooting)
	animation_tree.set('parameters/conditions/run', is_on_floor() and velocity and !is_shooting)
	animation_tree.set('parameters/conditions/jump', !is_on_floor())
	animation_tree.set('parameters/conditions/shoot', is_on_floor() and is_shooting and !velocity)
	animation_tree.set('parameters/conditions/walk_shoot', is_on_floor() and is_shooting and velocity)



''' Camera ''' 
func handle_camera_motion_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion :Vector2= event.screen_relative * mouse_sensitivity

		# Yaw
		rotate_y(-motion.x)

		# Pitch
		camera_pivot.rotate_x(-motion.y)
		
		# Clamp
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(up_rotate_limit),
			deg_to_rad(down_rotate_limit)
		)


''' Hurt + Die '''
func die():
	LevelManager.player_dead.emit()

func hurt(_health):
	flash(Color.RED)

func flash(color := Color.WHITE): # AI WRITTEN !!!
	# 1. Automatically locate ALL MeshInstance3D nodes under Mario (ear, head, body, legs, etc.)
	var meshes = mario.find_children("*", "MeshInstance3D", true, false)
	if meshes.is_empty():
		return
	# 2. Create a temporary pure white unshaded material overlay
	var overlay = StandardMaterial3D.new()
	overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	overlay.albedo_color = color
	
	overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# 3. Apply material_overlay to every mesh (covers all surfaces/materials of each mesh)
	for mesh in meshes:
		if mesh is MeshInstance3D:
			mesh.material_overlay = overlay
	# 4. If Mario gets hit rapidly, cancel the previous flash transition
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	# 5. Smoothly fade alpha from 1.0 to 0.0 over 0.15s, then remove overlay
	flash_tween = create_tween()
	flash_tween.tween_property(overlay, "albedo_color:a", 0.0, 0.15)
	flash_tween.tween_callback(func():
		for mesh in meshes:
			if is_instance_valid(mesh):
				mesh.material_overlay = null
	)




''' Collide Brick '''
func check_head_brick() -> void: # AI WRITTEN !!!
	if not head_ray.is_colliding():
		return
	
	var grid_map = head_ray.get_collider()
	
	if grid_map is GridMap:
		var hit_point: Vector3 = head_ray.get_collision_point()  # Move slightly up inside the brick
		var local_pos: Vector3 = grid_map.to_local(hit_point)
		var cell: Vector3i = grid_map.local_to_map(local_pos) + Vector3i(0,1,0)
		var item_id: int = grid_map.get_cell_item(cell)
		
		if item_id == 3: # If it is power bricks
			VfxManager.add_splittable(VfxManager.mushroom_splittable,hit_point,10)
		
		grid_map.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)
		
		# VFX + SFX
		VfxManager.add_vfx(VfxManager.break_bricks_vfx, hit_point)
		SfxManager.break_brick_sfx.play()



''' Collect stuff '''
func _on_magnet_body_entered(body: Node3D) -> void:
	if body is Collectible:
		body.start_collect(self)
