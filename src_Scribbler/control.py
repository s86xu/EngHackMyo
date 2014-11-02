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
    
    if abs(speed) < 0.15:
        if abs(turn) < 0.3:
            speedLeft, speedRight = 0, 0
        else:
            if turn > 0:
                speedLeft = 1
                speedRight = -1
            else:
                speedLeft = -1
                speedRight = 1
    elif abs(turn) < 0.3:
        speedLeft = max(speedLeft, speedRight)
        speedRight = speedLeft

    print "Motor:", speedLeft, speedRight
    motors(speedLeft, speedRight)

    if inp == "0 0":
        beep(1, 800)
