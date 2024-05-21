import os
from PIL import Image

name: str = "arrow"
max_width: int = 0
max_height: int = 0
images: list[Image.Image] = []
DIRECTORY = "./utilities/"

for file in os.listdir(DIRECTORY):
    if file.startswith(name):
        image = Image.open(DIRECTORY + file)
        images.append(image)
        max_width = max(max_width, image.width)
        max_height = max(max_height, image.height)

formatted: Image.Image = Image.new("RGBA", (max_width, max_height * len(images)))
for index, image in enumerate(images):
    formatted.paste(
        image, (round((max_width - image.width) / 2), round(index * max_height + (max_height - image.height) / 2))
    )
formatted.save(DIRECTORY + "formatted.png")
