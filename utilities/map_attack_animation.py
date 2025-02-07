from PIL import Image


def box_pos_size(x: int, y: int, width: int, height: int):
    return x, y, x + width, y + height


cell_size = 64
image_num = 9
img_offset = (256, 15)
tile_offset = (7, 7)
all_images = []
for image in range(1, image_num + 1):
    with Image.open(f'Swordmaster-f-{image}.png', 'r') as anim:
        box = box_pos_size(round(img_offset[0] + tile_offset[0] * 16 - (cell_size - 16) / 2),
                           round(img_offset[1] + tile_offset[1] * 16 - (cell_size - 16) / 2), cell_size, cell_size)
        all_images.append(anim.crop(box))

full_image = Image.new('RGB', (cell_size * image_num, cell_size), (128, 160, 128))
for i in range(image_num):
    full_image.paste(all_images[i], (i * cell_size, 0))
full_image.save('Formatted.png')
