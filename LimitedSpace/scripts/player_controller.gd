extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_SPEED: float = 4.5
const SENSITIVITY: Vector2 = Vector2(0.01, 0.01)
const CAMERA_ROTATION_LIMIT: Vector2 = Vector2(deg_to_rad(-90), deg_to_rad(90))
const GRAVITY: float = 9.8

const BOB_FREQUENCY: float = 2
const BOB_AMPLITUDE: float = 0.05

var headbob_time: float = 0

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
    Input.warp_mouse(Vector2.ZERO)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseMotion:
        head.rotate_y(-event.relative.x * SENSITIVITY.x)
        camera.rotate_x(-event.relative.y * SENSITIVITY.y)
        camera.rotation.x = clamp(camera.rotation.x, CAMERA_ROTATION_LIMIT.x, CAMERA_ROTATION_LIMIT.y)

func _physics_process(delta: float):
    if position.y < -10:
        position = Vector3(0,3,0)
        velocity = Vector3(0,0,0)
        return

    var is_grounded = is_on_floor()

    if not is_grounded:
        velocity.y -= GRAVITY * delta

    if Input.is_action_just_pressed("jump") and is_grounded:
        velocity.y = JUMP_SPEED

    var input_dir = Input.get_vector("left", "right", "up", "down")
    var dir = (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if dir != Vector3.ZERO:
        velocity.x = dir.x * SPEED
        velocity.z = dir.z * SPEED
    else:
        velocity.x = 0
        velocity.z = 0

    _headbob(delta, velocity.length(), is_grounded)

    move_and_slide()

func _headbob(delta: float, speed: float, is_grounded: bool):
    headbob_time += delta * speed * float(is_grounded)
    var pos_y = sin(headbob_time * BOB_FREQUENCY) * BOB_AMPLITUDE
    camera.position = Vector3(0, pos_y, 0)
