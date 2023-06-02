import cv2
import os

def extract_frames(video_path, output_dir, n):
    video = cv2.VideoCapture(video_path)
    frame_num = 0
    while video.isOpened():
        success, frame = video.read()
        if not success:
            break
        if frame_num % n == 0:  # check if this frame number is a multiple of n
            output_path = os.path.join(output_dir, f'frame_{frame_num}.png')
            cv2.imwrite(output_path, frame)
            print(f'Saved frame number {frame_num}')
        frame_num += 1
    video.release()
    cv2.destroyAllWindows()

absolute = os.path.dirname(os.path.realpath(__file__))

all_files = os.listdir(absolute)
for file in all_files:
    if file.upper().endswith(".MOV"):
        filename = os.path.splitext(file)[0]
        output_dir = os.path.join(absolute, filename)
        try:
            os.mkdir(output_dir)
        except:
            print("directory '" + filename + "' already exists")
            continue
        n = 60
        video_path = os.path.join(absolute, file)
        extract_frames(video_path, output_dir, n)
