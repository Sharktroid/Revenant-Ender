import os
from PIL import Image

all_chars = ["#","$","%","&","'","(",")","+",",","-",".","0","1","2","3","4","5","6","7","8","9","=","@","A","a","B","b","C","c","D","d","E","e","F","f","G","g","H","h","I","i","J","j","K","k","L","l","M","m","N","n","O","o","P","p","Q","q","R","r","S","s","T","t","u","U","v","V","w","W","x","X","y","Y","z","Z","[","]","^","{","}","~","ε"]
lowercase_chars: list[str] = []
uppercase_chars: list[str] = []
number_chars: list[str] = []
misc_chars: list[str] = []
full_list = [lowercase_chars, uppercase_chars, number_chars, misc_chars]

for char in all_chars:
    char_num = ord(char)
    if char_num >= 97 and char_num <= 122:
        lowercase_chars.append(char)
    elif char_num >= 65 and char_num <= 90:
        uppercase_chars.append(char)
    elif char_num >= 48 and char_num <= 57:
        number_chars.append(char)
    else:
        misc_chars.append(char)

max_length = 0
for lst in full_list:
    max_length = max(max_length, len(lst))

print(lowercase_chars)
print(uppercase_chars)
print(number_chars)
print(misc_chars)

full_image = Image.new('RGB', (16 * max_length, 16 * 4), (104, 136, 168))

for file in os.listdir():
    if ".png" in file and "FontItem" in file:
        parsed_name = file.replace("FontItem", "").split("_")[0]
        with Image.open(file, "r") as image:
            x = 0
            y = 0
            if parsed_name in lowercase_chars:
                x = lowercase_chars.index(parsed_name)
                y = 0
            elif parsed_name in uppercase_chars:
                x = uppercase_chars.index(parsed_name)
                y = 1
            elif parsed_name in number_chars:
                x = number_chars.index(parsed_name)
                y = 2
            elif parsed_name in misc_chars:
                x = misc_chars.index(parsed_name)
                y = 3
            full_image.paste(image, (16 * x, 16 * y))
full_image.save("full_text.png")