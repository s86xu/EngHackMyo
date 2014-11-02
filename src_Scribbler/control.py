# Hackathon 2014

from myro import *

init(raw_input("What is the COM port? "))

def isPositive(n):
    if n < 0:
        return False
    else:
        return True

while True:
    inp = raw_input()
    if inp == "0 0":
        beep(2, 800)
    turn, speed = map(float, inp.split())
    print turn, speed 
    
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
    
    if abs(turn) < 0.3 and abs(speed) < 0.15:
        speedLeft, speedRight = 0, 0
    motors(speedLeft, speedRight)
