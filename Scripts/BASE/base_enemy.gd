extends CharacterBody3D
class_name Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vision_box: Area3D = $VisionBox
@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var attack_cd: Timer = $attack_cd
@onready var attack_ray: RayCast3D = $AttackRay
@onready var knife_animation: AnimationPlayer = $KnifeAnimation
@onready var head_hurt_box: Area3D = $HeadHurtBox
@onready var head: Marker3D = $Head


@export var health_component: HealthComponent

var target: Player = null

''' Movement '''
@export_group('Movement')
@export var speed := 2

''' Attack '''
@export_group('Attack')
@export var damage: int = 1
@export var cd: float = 0.5
@export var knock_velocity: int = 7
var can_attack := true

''' Wander '''
const wander_radius := 5 
const max_wander_duration: float = 5
var original_position: Vector3 # Constrain to the born position
var wander_target_position: Vector3
var wander_duration := 0.0

''' State Machine '''
var current_state: State
enum State {
	IDLE,
	WANDER,
	CHASE,
	ATTACK,
}

''' Die '''
@export_group('Die')
@export var body_splittable: PackedScene
@export var mushroom_amount: int = 5







func _ready() -> void:
	health_component.dead.connect(die)
	health_component.health_changed.connect(hurt)
	head_hurt_box.body_entered.connect(head_hurt)
	
	original_position = global_position
	
func _physics_process(delta: float) -> void:
	pick_state()
	execute_state(delta)





func die():
	SfxManager.enemy_die_sfx.play()
	VfxManager.add_vfx(VfxManager.small_explosion_vfx, head.global_position)
	VfxManager.add_splittable(body_splittable, head.global_position)
	VfxManager.add_splittable(VfxManager.mushroom_splittable, head.global_position, mushroom_amount)
	queue_free()

func wander(delta: float):
	if wander_duration > 0:
		knife_animation.play('idle')
		move(wander_target_position)
		wander_duration -= delta
	elif wander_duration <= 0:
		# Get random position and duration
		wander_duration = randf_range(1, max_wander_duration)
		var x = randf_range(-wander_radius, wander_radius)
		var z = randf_range(-wander_radius, wander_radius)
		wander_target_position = original_position + Vector3(x, 0, z)



''' Movement '''
func move(target_position: Vector3):
	knife_animation.play('idle')
	nav_agent.target_position = target_position
	var next_position := nav_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	velocity = direction * speed
	
	# Rotation
	next_position.y = 0
	
	if global_position != next_position:
		look_at(next_position)
	
	move_and_slide()



''' Vision '''
func _on_vision_box_body_entered(body: Node3D) -> void:
	target = body

func _on_vision_box_body_exited(_body: Node3D) -> void:
	target = null



''' Attack '''
func _on_attack_cd_timeout() -> void:
	can_attack = true

func attack():
	knife_animation.play("attack")
	target.health_component.take_damage(damage)
	can_attack = false
	attack_cd.start(cd)
	# VFX + SFX
	var direction = (target.global_position - global_position).normalized()
	direction.y = 0
	VfxManager.add_vfx(VfxManager.blood_vfx, target.global_position, global_position)
	VfxManager.pop_score(VfxManager.pop_score_vfx, target.score_marker.global_position, -damage)
	SfxManager.knife_sfx.play()
	
	#target.apply_knock(direction * knock_velocity)


''' State Machine '''
func execute_state(delta: float):
	match current_state:
		State.WANDER:
			wander(delta)
		State.CHASE:
			move(target.global_position)
		State.ATTACK:
			attack()

func change_state(value: State):
	current_state = value

func pick_state():
	'''
	Order: 
		- Attack
		- Attack cd
		- Chase
		- Wander
	'''
	if target:
		if can_attack and attack_ray.is_colliding():
			change_state(State.ATTACK)
		elif !can_attack:
			change_state(State.IDLE)
		else:
			change_state(State.CHASE)
	else:
		change_state(State.WANDER)



''' Hurt '''
func hurt(_value):
	SfxManager.enemy_hurt_sfx.play()

func head_hurt(body: Player): # Step by player
	body.jump()
	health_component.dead.emit()
