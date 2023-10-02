extends Button

const scene_path: String = "res://scenes/gameplay.tscn"

func _ready():
    pressed.connect(_on_button_pressed)

func _on_button_pressed():
    get_tree().change_scene_to_file(scene_path)
