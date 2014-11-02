# Hackathon 2014

from myro import *

init(raw_input("What is the COM port? "))

# rotation and verdical
    

def isPositive(n):
    if n < 0:
        return False
    else:
        return True

while True:
    inp = raw_input()
    turn, speed = map(float, inp.split())
    
    if not -1 < turn < 1:
        turn = turn/abs(turn)

    if not -1 < speed < 1:
        speed = speed/abs(speed)

    speedLeft = speed
    speedRight = speed
    
    if isPositive(speed):
        if isPositive(turn):
            speedRight = speed - turn
        else:
            speedLeft = speed - abs(turn)
    else:
        if isPositive(turn):
            speedRight = speed + turn
        else:
            speedLeft = speed + abs(turn)
    
    motors(speedLeft, 0)
    motors(speedRight, 1)
