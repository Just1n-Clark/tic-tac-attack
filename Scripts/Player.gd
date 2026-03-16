extends CharacterBody3D

class_name Player

signal health_changed;

@onready var camera_pivot: Node3D = $camera_pivot
@onready var camera_mount: Node3D = $camera_pivot/camera_mount
@onready var impact_sound: AudioStreamPlayer3D = $impact_sound
@onready var mesh: MeshInstance3D = $mesh

@export var camera: Camera3D

#region Movement
const JUMP_VELOCITY = 4.5
var speed = 3

var do_dash = false;
var can_dash = true;
var dash_speed = 6;
var dash_duration = 0.2
var dash_cooldown = 2.0

var direction_blend_speed = 30.0;
#endregion

#region Camera
const CAMERA_ZOOM_SPEED = 0.1;
var min_camera_zoom = 4;
var max_camera_zoom = 8;
var min_camera_angle = deg_to_rad(-40);
var max_camera_angle = deg_to_rad(20);
var angle_fix_speed = 3;

@export var sens_horizontal = 0.3;
@export var sens_vertical = 0.3
#endregion

#region Health
const MAX_HEALTH = 60;
var current_health: float = MAX_HEALTH;

var is_dead = false;
#endregion

#region Combat
const ATTACK_RANGE = 2;

var damage = 10;
var next_attack = 0;
var attack_cooldown = 0.02;
#endregion

# Private Methods
func _ready() -> void:
	Global.player = self;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
func _input(event) -> void:
	if is_dead:
		return;

	if (event is InputEventMouseMotion):
		# Horizontal Look
		var horizontal_rotation = deg_to_rad(event.relative.x * sens_horizontal);
		camera_pivot.rotate_y(-horizontal_rotation);
		
		# Vertical look
		var vertical_rotation = deg_to_rad(-event.relative.y * sens_vertical);
		camera_mount.rotate_x(vertical_rotation);
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z -= CAMERA_ZOOM_SPEED;
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z += CAMERA_ZOOM_SPEED;

		camera.position.z = clamp(camera.position.z, min_camera_zoom, max_camera_zoom);
		
func _physics_process(delta: float) -> void:
	if is_dead:
		return;
	
	# Camera clamping smooths between values
	_clamp_and_smooth_camera(delta);
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("dash") and can_dash:
		_dash();

	set_velocity_and_direction(delta);
	
	# Attack
	next_attack += delta;
	if (Input.is_action_just_pressed("attack")):
			_perform_attack();

	move_and_slide();
	
func set_velocity_and_direction(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (camera_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if do_dash:
		var dash_direction = mesh.transform.basis.z.normalized();
		velocity = -dash_direction * speed * dash_speed;
		velocity.y = 0;
		
		_create_dash_effect();
	elif direction:
		var target_transform = Transform3D.IDENTITY.looking_at(direction, Vector3.UP);
		mesh.basis = mesh.basis.slerp(target_transform.basis, direction_blend_speed * delta);
		
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);

func _clamp_and_smooth_camera(delta):
	var t = inverse_lerp(min_camera_zoom, max_camera_zoom, camera.position.z);
	
	var target_max_angle = lerp(deg_to_rad(17), deg_to_rad(20), t);
	var target_min_angle = lerp(deg_to_rad(-60), deg_to_rad(-40), t);
	min_camera_angle = lerp(min_camera_angle, target_min_angle, angle_fix_speed * delta);
	max_camera_angle = lerp(max_camera_angle, target_max_angle, angle_fix_speed * delta);
	
	camera_mount.rotation.x = clamp(camera_mount.rotation.x, min_camera_angle, max_camera_angle);
	
func _dash():
	can_dash = false
	do_dash = true
	
	await get_tree().create_timer(dash_duration).timeout;
	
	do_dash = false
	
	await get_tree().create_timer(dash_cooldown).timeout;
	
	can_dash = true;
		
func _die():
	is_dead = true;
	print("Player died!");
	
	await get_tree().create_timer(3.0).timeout;
	
	is_dead = false;
	_respawn();
	
func _respawn():
	current_health = MAX_HEALTH;
	print("Player respawned");
	
func _perform_attack():
	# Check if in range to attack enemy
	var enemies = get_tree().get_nodes_in_group("enemy");
	var closest_enemy = null;
	var closest_distance = INF;
	
	for enemy in enemies:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		if (distance_to_enemy < ATTACK_RANGE):
			if (distance_to_enemy < closest_distance):
				closest_distance = distance_to_enemy;
				closest_enemy = enemy;
				
	if next_attack > attack_cooldown and closest_enemy != null:
		next_attack = 0;
		closest_enemy.take_damage(damage);
		impact_sound.play();
	
# Dash ghost effect inspired by gamedevjourney.co.uk
func _create_dash_effect():
	var visual_copy_of_player = mesh.duplicate();
	var material_copy = visual_copy_of_player.get_active_material(0).duplicate();
	material_copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_copy.albedo_color.a = 0.1;
	visual_copy_of_player.set_surface_override_material(0, material_copy);
	
	# Add visual copy to scene
	get_parent().add_child(visual_copy_of_player);
	visual_copy_of_player.global_position = global_position;
	
	await get_tree().create_timer(dash_duration).timeout;
	
	visual_copy_of_player.queue_free();
	
# Public methods
func take_damage(damage: float):
	if is_dead:
		return;
	
	current_health -= damage;
	current_health = clamp(current_health, 0, MAX_HEALTH);
	
	health_changed.emit();
	
	if (current_health < 1):
		_die();
