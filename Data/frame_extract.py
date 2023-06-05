import cv2
import os
from datetime import datetime

def extract_frames(video_path, output_dir, n, prefix):
    video = cv2.VideoCapture(video_path)
    frame_num = 0
    while video.isOpened():
        success, frame = video.read()
        if not success:
            break
        if frame_num % n == 0:  # check if this frame number is a multiple of n
            output_path = os.path.join(output_dir, f'{prefix}_frame_{frame_num}.jpg')
            cv2.imwrite(output_path, frame)
            # print(f'{prefix}: Saved frame {frame_num}')
        frame_num += 1
    video.release()
    cv2.destroyAllWindows()
    print("COMPLETED SET: " + prefix + " (" + video_path + ")")

absolute = os.path.join(os.path.dirname(os.path.realpath(__file__)), "Training")
current_datetime = datetime.now()
formatted_datetime = current_datetime.strftime("%d.%m.%Y-%H.%M")
OUTPUT_DIR = os.path.join(absolute, "output-" + formatted_datetime)
CATEGORIES_DIR = os.path.join(absolute, "raw_categories")
BACKGROUND_DIR = os.path.join(absolute, "raw_background")
os.mkdir(OUTPUT_DIR)

print("STARTING CATEGORIES")
# Generate categories
all_category_folders = os.listdir(CATEGORIES_DIR)
for category_folder in all_category_folders:
    if "." in category_folder:
        continue
    output_dir = os.path.join(OUTPUT_DIR, category_folder)
    try:
        os.mkdir(output_dir)
    except:
        print("> directory '" + output_dir + "' already exists")
    all_videos = os.listdir(os.path.join(CATEGORIES_DIR, category_folder))
    for index, video in enumerate(all_videos):
        if not video.upper().endswith(".MOV"):
            continue
        video_path = os.path.join(CATEGORIES_DIR, category_folder, video)
        extract_frames(video_path, output_dir, 90, category_folder + str(index))
print("COMPLETED CATEGORIES")

print("STARTING BACKGROUND")
# Generate background
all_background_folders = os.listdir(BACKGROUND_DIR)
for background_folder in all_background_folders:
    if "." in background_folder:
        continue
    output_dir = os.path.join(OUTPUT_DIR, "background")
    try:
        os.mkdir(output_dir)
    except:
        pass
    all_videos = os.listdir(os.path.join(BACKGROUND_DIR, background_folder))
    for index, video in enumerate(all_videos):
        if not video.upper().endswith(".MOV"):
            continue
        video_path = os.path.join(BACKGROUND_DIR, background_folder, video)
        extract_frames(video_path, output_dir, 90, background_folder + str(index))
print("COMPLETED BACKGROUND")