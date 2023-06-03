import cv2
import os

absolute = os.path.dirname(os.path.realpath(__file__))
output_dir = os.path.join(absolute, "output-04.06.2023-05.38")
for folder in os.listdir(output_dir):
    if "." in folder:
        continue
    print(folder)
    for image in os.listdir(os.path.join(output_dir, folder)):
        if image.upper().endswith(".PNG"):
            img = cv2.imread(os.path.join(output_dir, folder, image))
            if img is None or img.shape[0] == 0 or img.shape[1] == 0:
                print(f"Invalid image: {image}")
