extends CharacterBody3D

const SPEED = 5
const JUMP_SPEED = 4.5
const SENSITIVITY = 0.03
const CAMERA_ROTATION_LIMIT = Vector2(deg_to_rad(-40), deg_to_rad(60))

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _unhandled_input(event):
    if event is InputEventMouseMotion:
        head.rotate_y(-event.relative.x * SENSITIVITY)
        camera.rotate_x(-event.relative.y * SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, CAMERA_ROTATION_LIMIT.x, CAMERA_ROTATION_LIMIT.y)

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_SPEED

    var input_dir = Input.get_vector("left", "right", "up", "down")
    var dir = (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if dir != Vector3.ZERO:
        velocity.x = dir.x * SPEED
        velocity.z = dir.z * SPEED
    else:
        velocity.x = 0
        velocity.z = 0

    if position.y < -10:
        position = Vector3(0,3,0)
        velocity = Vector3(0,0,0)

    move_and_slide()
