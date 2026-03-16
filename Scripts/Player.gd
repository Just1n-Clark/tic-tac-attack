extends CharacterBody3D

@onready var camera_pivot: Node3D = $camera_pivot
@onready var camera_mount: Node3D = $camera_pivot/camera_mount
@export var camera: Camera3D
@onready var mesh: MeshInstance3D = $mesh

const JUMP_VELOCITY = 4.5

var SPEED = 2.5

var walking_speed = 3.0
var running_speed = 5.0

var direction_blend_speed = 10.0;

# Camera
const CAMERA_ZOOM_SPEED = 0.1;
var min_camera_zoom = 4;
var max_camera_zoom = 8;
var min_camera_angle = deg_to_rad(-40);
var max_camera_angle = deg_to_rad(20);
var angle_fix_speed = 3;

# Health
const MAX_HEALTH = 30;
var current_health = 0;

# Combat
const ATTACK_DISTANCE = 2;

var damage = 10;
var next_attack = 0;
var attack_cooldown = 1;

@export var enemy : CharacterBody3D;

@export var sens_horizontal = 0.3;
@export var sens_vertical = 0.3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
	current_health = MAX_HEALTH;
	
func _input(event) -> void:
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
	# Camera clamping smooths between values
	clamp_and_smooth_camera(delta);
	
	# Sprinting
	if (Input.is_action_pressed("run")):
		SPEED = running_speed;
	else:
		SPEED = walking_speed;
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	set_velocity_and_direction(delta);
	
	if (enemy != null):
		next_attack += delta;
		
		# Check if able to damage enemy
		if global_position.distance_to(enemy.global_position) < ATTACK_DISTANCE:
			if next_attack > attack_cooldown:
				next_attack = 0;
				enemy.take_damage(damage);

	move_and_slide();
	
func set_velocity_and_direction(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (camera_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var target_transform = Transform3D.IDENTITY.looking_at(direction, Vector3.UP);
		mesh.basis = mesh.basis.slerp(target_transform.basis, direction_blend_speed * delta);
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func clamp_and_smooth_camera(delta):
	var t = inverse_lerp(min_camera_zoom, max_camera_zoom, camera.position.z);
	
	var target_max_angle = lerp(deg_to_rad(17), deg_to_rad(20), t);
	var target_min_angle = lerp(deg_to_rad(-60), deg_to_rad(-40), t);
	min_camera_angle = lerp(min_camera_angle, target_min_angle, angle_fix_speed * delta);
	max_camera_angle = lerp(max_camera_angle, target_max_angle, angle_fix_speed * delta);
	
	camera_mount.rotation.x = clamp(camera_mount.rotation.x, min_camera_angle, max_camera_angle);
	
func take_damage(damage: float):
	current_health -= damage;
	current_health = clamp(current_health, 0, MAX_HEALTH);
	
	print("Health: %d" % current_health);
	
	if (current_health < 1):
		die();
		
func die():
	print("Player died!");
	
func respawn():
	current_health = MAX_HEALTH;
	print("Player respawned")
