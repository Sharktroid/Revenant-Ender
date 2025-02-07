from PIL import Image

def get_standing_tile(standing, column, row):
    img = Image.new('RGB', (24, 24), (128, 160, 128))
    img.paste(standing.crop((column * 16, 16 * row, (column + 1) * 16, int(16) * (row + 1))), (4, 8))
    return img


def get_walking_tile(walking, column, row):
    return walking.crop((24 * column, 24 * row, 24 * (column + 1), 24 * (row + 1)))


all_images = []
name = 'menu_bottom.png'
with Image.open(name, 'r') as menu:
    left = menu.crop((0, 0, 16, 5))
    mid = menu.crop((16, 0, 16+8, 5))
    right = menu.crop((40, 0, 48, 5))

# left.show()
# mid.show()
# right.show()
left.save(name.replace('.', '_left.'))
mid.save(name.replace('.', '_mid.'))
right.save(name.replace('.', '_right.'))