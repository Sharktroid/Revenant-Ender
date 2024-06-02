from PIL import Image


class Vector:
    x: int
    y: int

    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

color = 0, 0, 112
full_image = Image.new("RGB", (32 * 4, 32 * 5), (0, 0, 112))

with Image.open("utilities/map_sprite_sheet.png", "r") as sprite_sheet:
    idle_section = sprite_sheet.crop((16, 84, 32, 156))
    moving_section = sprite_sheet.crop((40, 32, 168, 160))

for index in range(3):
    frame_dimensions = Vector(idle_section.width, round(idle_section.height / 3))
    full_image.paste(
        idle_section.crop(
            (
                0,
                index * frame_dimensions.y,
                frame_dimensions.x,
                (index + 1) * frame_dimensions.y,
            )
        ),
        ((index) * 32 + 16 - round(frame_dimensions.x / 2), 16 - round(frame_dimensions.y / 2)),
    )


full_image.paste(moving_section, (0, 32))

full_image.show()
# full_image.save("utilities/map_sprite.png")
