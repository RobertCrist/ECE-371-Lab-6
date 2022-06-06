
# Import the required libraries
from tkinter import *
from array import *


# Create an instance of Tkinter Frame
root = Tk()

# Set the geometry
root.geometry("1920x1080")
root.resizable(True, True)

class pixel:
   
   
   def __init__(self, main, xPos, yPos):
      self.myButton = Button(main, text="", width = 1, height = 1, command=self.change_color)
      self.myButton.place(x = xPos + 2 , y = 2 + yPos) 
      self.wall = False
   
   def change_color(self):
      self.wall = not self.wall
      if(self.wall):
         self.myButton.configure(bg = "black")
      else:
         self.myButton.configure(bg = "white")
   
   def get_wall(self):
      return self.wall
      

# pixels =  [pixel(root, 0, 0), pixel(root, 18, 0)] 
# test = pixel(root, 0, 0)


pixels = []
mifData = []
for i in range(30):
   temp = []
   for j in range(80):
      temp.append(pixel(root, 18 * j, 28*i))
   pixels.append(temp)

def generateMif():
   mifData.clear()
   for i in range(30):
      temp = 0
      for j in range(80):
         if(pixels[i][j].get_wall()):
            temp = temp + 2**j
      mifData.append(temp)
   for i in range(30):
      line = '	' + str(i + 210) + '	:	' + str(mifData[i]) + ';'
      print(line)



generate = Button(root, text="Generate", command=generateMif)
generate.place(x= 1680, y = 540)


root.mainloop() 

