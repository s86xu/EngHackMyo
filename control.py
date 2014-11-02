# Hackathon 2014

from myro import *

init(raw_input("What is the COM port? "))

while True:
    key = raw_input()
    if key == "f":
        forward()
    elif key == "r":
        backward()
    elif key == "t":
        spd = input()
        turn(spd)
    elif key == "s":
        stop()


def forward():
    move(1,0)

def backward():
    move(-1,0)

def turn(speed):
    rotate(speed)

