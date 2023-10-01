extends CharacterBody3D

const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 8.0
const CROUCH_SPEED: float = 2.0
const JUMP_SPEED: float = 4.5
const CURSOR_SENSITIVITY: float = 0.005
const CAMERA_ROTATION_LIMIT: Vector2 = Vector2(deg_to_rad(-90), deg_to_rad(90))
const GRAVITY: float = 9.8
const HEADBOB_FREQUENCY: float = 2
const HEADBOB_AMPLITUDE: float = 0.05
const RAY_LENGTH: float = 2
const REGULAR_LAYER: int = 1

var headbob_time: float = 0
var jumping: bool = false
var crouching: bool = false
var last_interaction: InteractiveObject = null

@export var audio_step_sfx: AudioStream
@export var audio_jump_sfx: AudioStream
@export var audio_land_sfx: AudioStream

@onready var head: Node3D = $Head
@onready var camera: Node3D = $Head/Camera3D
@onready var effects_camera: Camera3D = $Head/OutlineViewport/OutlineCamera
@onready var foot_audio_player: AudioStreamPlayer3D = $Foot/AudioStreamPlayer3D

func _ready():
    Input.warp_mouse(Vector2.ZERO)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseMotion:
        head.rotate_y(-event.relative.x * CURSOR_SENSITIVITY)
        camera.rotate_x(-event.relative.y * CURSOR_SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, CAMERA_ROTATION_LIMIT.x, CAMERA_ROTATION_LIMIT.y)

func _physics_process(delta: float):
    if position.y < -10:
        position = Vector3(0,3,0)
        velocity = Vector3(0,0,0)
        return

    var is_grounded = is_on_floor()

    if not is_grounded:
        velocity.y -= GRAVITY * delta
        crouching = false
    elif jumping: # was jumping + is grounded = landing
        _play_foot_sfx(audio_land_sfx)
        jumping = false

    if Input.is_action_just_pressed("crouch") and is_grounded:
        crouching = not crouching

    if Input.is_action_just_pressed("jump") and is_grounded:
        jumping = true
        crouching = false
        velocity.y = JUMP_SPEED
        _play_foot_sfx(audio_jump_sfx)

    var speed: float
    if Input.is_action_pressed("sprint"):
        speed = SPRINT_SPEED
    elif crouching:
        speed = CROUCH_SPEED
    else:
        speed = WALK_SPEED

    var input_dir = Input.get_vector("left", "right", "up", "down")
    var dir = (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if dir != Vector3.ZERO:
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
    else:
        velocity.x = 0
        velocity.z = 0
        speed = 0

    _headbob(delta, speed, is_grounded and not jumping)

    move_and_slide()

    _check_interaction()

func _process(_delta):
    effects_camera.global_transform = camera.global_transform

func _headbob(delta: float, speed: float, is_grounded: bool):
    headbob_time += delta * speed * float(is_grounded)
    var pos_y = sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_AMPLITUDE
    camera.position = Vector3(0, pos_y, 0)

func _play_foot_sfx(sfx: AudioStream):
    foot_audio_player.stop()
    foot_audio_player.stream = sfx
    foot_audio_player.play()

func _check_interaction():
    var state = get_world_3d().direct_space_state
    var ray_query = PhysicsRayQueryParameters3D.new()
    ray_query.from = camera.global_position
    ray_query.to = ray_query.from - camera.global_transform.basis.z * RAY_LENGTH
    ray_query.collide_with_bodies = true
    ray_query.collision_mask = ~2
    var result = state.intersect_ray(ray_query)
    if result:
        #print("Hit: ", result.collider.name)
        var obj = result.collider as InteractiveObject
        if obj:
            last_interaction = obj
            last_interaction.set_outline(true)
        else:
            _clear_interaction()
    else:
        _clear_interaction()

func _clear_interaction():
    if last_interaction:
        last_interaction.set_outline(false)
        last_interaction = null
