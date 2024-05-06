import os
from PIL import Image

# constants
PORTRAIT_WIDTH = 96
PORTRAIT_HEIGHT = 80
MOUTH_WIDTH = 32
MOUTH_HEIGHT = 16
MOUTH_FRAME_0_X = 96
MOUTH_FRAME_0_Y = 80
NEUTRAL_MOUTH_FRAME_1_X = 0
NEUTRAL_MOUTH_FRAME_1_Y = 96
NEUTRAL_MOUTH_FRAME_2_X = NEUTRAL_MOUTH_FRAME_1_X
NEUTRAL_MOUTH_FRAME_2_Y = NEUTRAL_MOUTH_FRAME_1_Y - MOUTH_HEIGHT
HAPPY_MOUTH_FRAME_1_X = NEUTRAL_MOUTH_FRAME_1_X + MOUTH_WIDTH
HAPPY_MOUTH_FRAME_1_Y = NEUTRAL_MOUTH_FRAME_1_Y
HAPPY_MOUTH_FRAME_2_X = HAPPY_MOUTH_FRAME_1_X
HAPPY_MOUTH_FRAME_2_Y = HAPPY_MOUTH_FRAME_1_Y - MOUTH_HEIGHT

name = input("Enter unit's name: ")
mouth_x: int = int(input("Enter mouth x coordinate: "))
mouth_y: int = int(input("Enter mouth y coordinate: "))

DIRECTORY = f"portraits\\{name}"

scene = f"""[gd_scene load_steps=5 format=3 uid="uid://6wmdutxgincw"]

[ext_resource type="PackedScene" path="res://portraits/portrait.tscn" id="1_5bn21"]
[ext_resource type="Texture2D" path="res://portraits/{name}/portrait.png" id="2_vuq7b"]
[ext_resource type="Texture2D" path="res://portraits/{name}/talking.png" id="3_h8b72"]
[ext_resource type="Texture2D" path="res://portraits/{name}/talking-happy.png" id="4_85h1k"]

[node name="{name.capitalize()}" instance=ExtResource("1_5bn21")]
texture = ExtResource("2_vuq7b")

[node name="Mouth" parent="." index="0"]
position = Vector2({mouth_x * 8}, {mouth_y * 8})
texture = ExtResource("3_h8b72")

[node name="MouthHappy" parent="." index="1"]
position = Vector2({mouth_x * 8}, {mouth_y * 8})
texture = ExtResource("4_85h1k")
"""

with Image.open("utilities\\portrait.png", "r").convert("RGBA") as image:
    for x in range(image.width):
        for y in range(image.height):
            if image.getpixel((x, y)) == (120, 160, 112, 255):
                image.putpixel((x, y), 0)
    portrait = image.crop((0, 0, PORTRAIT_WIDTH, PORTRAIT_HEIGHT))
    talking = Image.new("RGBA", (MOUTH_WIDTH, MOUTH_HEIGHT * 3))
    talking.paste(image.crop((MOUTH_FRAME_0_X, MOUTH_FRAME_0_Y, MOUTH_FRAME_0_X + MOUTH_WIDTH, MOUTH_FRAME_0_Y + MOUTH_HEIGHT)), (0, 0))
    talking_happy = talking.copy()
    talking.paste(image.crop((NEUTRAL_MOUTH_FRAME_1_X, NEUTRAL_MOUTH_FRAME_1_Y, NEUTRAL_MOUTH_FRAME_1_X + MOUTH_WIDTH, NEUTRAL_MOUTH_FRAME_1_Y + MOUTH_HEIGHT)), (0, MOUTH_HEIGHT))
    talking.paste(image.crop((NEUTRAL_MOUTH_FRAME_2_X, NEUTRAL_MOUTH_FRAME_2_Y, NEUTRAL_MOUTH_FRAME_2_X + MOUTH_WIDTH, NEUTRAL_MOUTH_FRAME_2_Y + MOUTH_HEIGHT)), (0, MOUTH_HEIGHT * 2))
    talking_happy.paste(image.crop((HAPPY_MOUTH_FRAME_1_X, HAPPY_MOUTH_FRAME_1_Y, HAPPY_MOUTH_FRAME_1_X + MOUTH_WIDTH, HAPPY_MOUTH_FRAME_1_Y + MOUTH_HEIGHT)), (0, MOUTH_HEIGHT))
    talking_happy.paste(image.crop((HAPPY_MOUTH_FRAME_2_X, HAPPY_MOUTH_FRAME_2_Y, HAPPY_MOUTH_FRAME_2_X + MOUTH_WIDTH, HAPPY_MOUTH_FRAME_2_Y + MOUTH_HEIGHT)), (0, MOUTH_HEIGHT * 2))
    if not os.path.exists(DIRECTORY):
        os.mkdir(DIRECTORY)
    portrait.save(f"{DIRECTORY}\\portrait.png")
    talking.save(f"{DIRECTORY}\\talking.png")
    talking_happy.save(f"{DIRECTORY}\\talking-happy.png")

with open(f"{DIRECTORY}\\{name}.tscn", "w") as file:
    file.write(scene)
