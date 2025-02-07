from math import floor
from PIL import Image


def get_standing_tile(standing: Image.Image, row: int):
    img = Image.new("RGB", (32, 32), (128, 160, 128))
    img.paste(
        standing.crop(
            (
                0,
                int(standing.size[1] / 3) * row,
                16,
                int(standing.size[1] / 3) * (row + 1),
            )
        ),
        (8, 32 - int(standing.size[1] / 3)),
    )
    return img


def get_walking_tile(walking: Image.Image, row: int):
    return walking.crop((0, 32 * row, 32, 32 * (row + 1)))


all_images: list[Image.Image] = []

with Image.open("stand.png", "r") as standing:
    for i in range(3):
        all_images.append(get_standing_tile(standing, i))
all_images.append(Image.new("RGB", (32, 32), (128, 160, 128)))

with Image.open("walk.png", "r") as walking:
    for i in range(15):
        all_images.append(get_walking_tile(walking, i))
all_images.append(Image.new("RGB", (32, 32), (128, 160, 128)))

full_image = Image.new("RGB", (32 * 4, 32 * 5), (128, 160, 128))
for i in range(20):
    full_image.paste(all_images[i], ((i % 4) * 32, (floor(i / 4)) * 32))
full_image.save("Formatted.png")
