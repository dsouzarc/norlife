import os


#Written by Ryan Dsouza
#Quickly renames all the photos in a directory with the format
#'Screenshot_X.png', where X is that file's place in the directory

#Also prints out the markdown code to display these many images

#Run instructions: 'python ImageRenamer.py'


files = os.listdir('.')
index = 0

project_name = "norlife"
png_screenshots = True

prefix = "https://github.com/dsouzarc/" + project_name + "/blob/master/Screenshots/";

for file_name in sorted(files):

    if file_name != "ImageRenamer.py" or (png_screenshots and ".png" in file_name):
        if "Screenshot_" in file_name:
            index += 1;

for file_name in sorted(files):

    if ("Screenshot_" not in file_name and file_name != "ImageRenamer.py" 
        or (png_screenshots and '.png' in file_name)):

            new_file_name = "Screenshot_" + str(index) + ".png"
            os.rename(file_name, new_file_name)
            print("![Screenshot " + str(index) + "](" + prefix + new_file_name + ")")
            index += 1

