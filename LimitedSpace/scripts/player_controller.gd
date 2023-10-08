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
const HEADBOB_OFFSET: float = PI
const RAY_LENGTH: float = 3
const REGULAR_LAYER: int = 1
const INTERACTION_LAYER_MASK: int = ~2
const CROUCH_TIME: float = 0.3
const CROUCH_Y: float = 0.5
const STANDING_Y: float = 1.0

var _headbob_time: float = 0
var _jumping: bool = false
var _crouching: bool = false
var _last_interaction: InteractiveObject = null
var _crouch_tween: Tween = null

@export_category("Assets")
@export var audio_step_sfx: AudioStream
@export var audio_jump_sfx: AudioStream
@export var audio_land_sfx: AudioStream

@export_category("Scene References")
@export var object_name_label: Label

@onready var head: Node3D = $Head
@onready var camera: Node3D = $Head/Camera3D
@onready var effects_camera: Camera3D = $Head/OutlineViewport/OutlineCamera
@onready var foot_audio_player: AudioStreamPlayer3D = $Foot/AudioStreamPlayer3D

@onready var message_controller: MessageController = $"/root/Gameplay/MessageController"

func _ready():
    Input.warp_mouse(Vector2.ZERO)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
    object_name_label.text = ""

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseMotion:
        self.rotate_y(-event.relative.x * CURSOR_SENSITIVITY)
        camera.rotate_x(-event.relative.y * CURSOR_SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, CAMERA_ROTATION_LIMIT.x, CAMERA_ROTATION_LIMIT.y)

func _physics_process(delta: float):
    if Input.is_action_just_pressed("escape") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

    if position.y < -10:
        position = Vector3(0,1,0)
        velocity = Vector3(0,0,0)
        return

    var is_grounded = is_on_floor()

    if not is_grounded:
        velocity.y -= GRAVITY * delta
        _crouching = false
    elif _jumping: # was jumping + is grounded = landing
        _play_foot_sfx(audio_land_sfx)
        _jumping = false

    if Input.is_action_just_pressed("crouch") and is_grounded:
        _crouching = not _crouching
        if _crouch_tween:
            _crouch_tween.kill()
        _crouch_tween = get_tree().create_tween()
        _crouch_tween.tween_property(self, "scale:y", CROUCH_Y if _crouching else STANDING_Y, CROUCH_TIME)
        _crouch_tween.play()

    if Input.is_action_just_pressed("jump") and is_grounded:
        _jumping = true
        _crouching = false
        velocity.y = JUMP_SPEED
        _play_foot_sfx(audio_jump_sfx)

    var speed: float
    if Input.is_action_pressed("sprint"):
        speed = SPRINT_SPEED
    elif _crouching:
        speed = CROUCH_SPEED
    else:
        speed = WALK_SPEED

    var input_dir = Input.get_vector("left", "right", "up", "down")
    var dir = (self.basis * Vector3(-input_dir.y, 0, input_dir.x)).normalized()

    if dir != Vector3.ZERO:
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
    else:
        velocity.x = 0
        velocity.z = 0
        speed = 0

    _headbob(delta, speed, is_grounded and not _jumping)

    move_and_slide()

    _check_interaction()

func _process(_delta):
    effects_camera.global_transform = camera.global_transform

func _headbob(delta: float, speed: float, is_grounded: bool):
    _headbob_time += delta * speed * float(is_grounded) * HEADBOB_FREQUENCY
    if _headbob_time > 2*PI:
        _headbob_time -= 2*PI
        _play_foot_sfx(audio_step_sfx)
    var pos_y = sin(_headbob_time + HEADBOB_OFFSET) * HEADBOB_AMPLITUDE
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
    ray_query.collision_mask = INTERACTION_LAYER_MASK
    var result = state.intersect_ray(ray_query)
    if result: # object hit
        var obj = result.collider as InteractiveObject
        if not obj == _last_interaction: # ignore if nothing changed
            if obj:
                _clear_interaction()
                _last_interaction = obj
                _last_interaction.set_outline(true)
                object_name_label.text = _last_interaction.object_name
            else: # object not interactive
                _clear_interaction()
    else: # no object hit
        _clear_interaction()
    _interact()

func _clear_interaction():
    if _last_interaction:
        _last_interaction.set_outline(false)
        _last_interaction = null
        object_name_label.text = ""

func _interact():
    if Input.is_action_just_pressed("interact"):
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.warp_mouse(Vector2.ZERO)
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
        if _last_interaction:
            var removed = _last_interaction.interact()
            if removed:
                _last_interaction = null
