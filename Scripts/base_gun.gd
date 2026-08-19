extends Node3D
class_name Gun

@onready var muzzle: Marker3D = $Muzzle
@onready var muzzle_flash: GPUParticles3D = $Muzzle/MuzzleFlash
@onready var ak_47: Node3D = $"ak-47"
@onready var floating_component: FloatingComponent = $FloatingComponent

@export var stats: GunStats
@export var interact_box: InteractableBox

var current_ammo: int

func _ready() -> void:
	current_ammo = stats.ammo
	
	interact_box.interact.connect(on_interact)

func shoot_bullet(direction: Vector3):
	var bullet: Bullet = stats.bullet_path.instantiate()
	# Shoot bullet 
	get_tree().current_scene.add_child(bullet)
	
	# Init the bullet
	bullet.stats = stats
	bullet.global_position = muzzle.global_position
	bullet.direction = direction
	
	# Play vfx
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func on_interact(body: Player):
	self.reparent(body.gun_holder, false)
	
	interact_box.process_mode = Node.PROCESS_MODE_DISABLED
	floating_component.reset_position()
	floating_component.process_mode = Node.PROCESS_MODE_DISABLED
	
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	SfxManager.gun_reload_sfx.play()
	
	body.can_shoot = true
