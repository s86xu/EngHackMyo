// Copyright (C) 2013-2014 Thalmic Labs Inc.
// Distributed under the Myo SDK license agreement. See LICENSE.txt for details.
#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>
#include <iomanip>
#include <stdexcept>
#include <string>
#include <algorithm>
#include <stdlib.h>

// The only file that needs to be included to use the Myo C++ SDK is myo.hpp.
#include <myo/myo.hpp>

// Classes that inherit from myo::DeviceListener can be used to receive events from Myo devices. DeviceListener
// provides several virtual functions for handling different kinds of events. If you do not override an event, the
// default behavior is to do nothing.
class DataCollector : public myo::DeviceListener
{
public:
    DataCollector()
        : onArm(false), roll_w(0), pitch_w(0), yaw_w(0), currentPose()
    {
    }

    void init(myo::Myo* myo)
    {
        c = 0;
        this->myo = myo;
        DISTANCE = 0.05;
    }

    // onUnpair() is called whenever the Myo is disconnected from Myo Connect by the user.
    void onUnpair(myo::Myo* myo, uint64_t timestamp)
    {
        // We've lost a Myo.
        // Let's clean up some leftover state.
        roll_w = 0;
        pitch_w = 0;
        yaw_w = 0;
        onArm = false;
    }

    // onOrientationData() is called whenever the Myo device provides its current orientation, which is represented
    // as a unit quaternion.
    void onOrientationData(myo::Myo* myo, uint64_t timestamp, const myo::Quaternion<float>& quat)
    {
        using std::atan2;
        using std::asin;
        using std::sqrt;
        using std::max;
        using std::min;

        // Calculate Euler angles (roll, pitch, and yaw) from the unit quaternion.
        float roll = atan2(2.0f * (quat.w() * quat.x() + quat.y() * quat.z()),
                           1.0f - 2.0f * (quat.x() * quat.x() + quat.y() * quat.y()));
        float pitch = asin(max(-1.0f, min(1.0f, 2.0f * (quat.w() * quat.y() - quat.z() * quat.x()))));
        float yaw = atan2(2.0f * (quat.w() * quat.z() + quat.x() * quat.y()),
                          1.0f - 2.0f * (quat.y() * quat.y() + quat.z() * quat.z()));
        roll_w = roll;
        pitch_w = pitch;
        yaw_w = yaw;
    }

    // onArmRecognized() is called whenever Myo has recognized a Sync Gesture after someone has put it on their
    // arm. This lets Myo know which arm it's on and which way it's facing.
    void onArmRecognized(myo::Myo* myo, uint64_t timestamp, myo::Arm arm, myo::XDirection xDirection)
    {
        onArm = true;
        whichArm = arm;
    }

    // onArmLost() is called whenever Myo has detected that it was moved from a stable position on a person's arm after
    // it recognized the arm. Typically this happens when someone takes Myo off of their arm, but it can also happen
    // when Myo is moved around on the arm.
    void onArmLost(myo::Myo* myo, uint64_t timestamp)
    {
        onArm = false;
    }

    float roundTo(float n)
    {
        float pow = 1000;
        return floor(n*pow + 0.5)/pow;
    }

    // onPose() is called whenever the Myo detects that the person wearing it has changed their pose, for example,
    // making a fist, or not making a fist anymore.
    void onPose(myo::Myo* myo, uint64_t timestamp, myo::Pose pose)
    {
        currentPose = pose;

        // Vibrate the Myo whenever we've detected that the user has made a fist.
        if (pose == myo::Pose::fist) {
            //myo->vibrate(myo::Myo::vibrationMedium);
        }
    }

    // There are other virtual functions in DeviceListener that we could override here, like onAccelerometerData().
    // For this example, the functions overridden above are sufficient.

    // We define this function to print the current values that were updated by the on...() functions above.
    void loop(float target[])
    {
        c++;
        if (c > absol(distance(target))*50)
        {
            c = 0;
            myo->vibrate(myo::Myo::vibrationShort);
        }
        // Clear the current line
        std::cout << '\r';

        std::cout << "Target: ";
        for (int i=0; i<3; i++)
        {
            std::cout << roundTo(target[i]) << " ";
        }

        // Print out the orientation. Orientation data is always available, even if no arm is currently recognized.
        std::cout << "Actual: "
                  << roundTo(roll_w) << '\t'
                  << roundTo(pitch_w) << '\t'
                  << roundTo(yaw_w);
        std::cout << "             ";
        std::cout << std::flush;
    }

    bool isWin(float target[])
    {
        float dist = distance(target);
        if (absol(dist) < DISTANCE)
        {
            myo->vibrate(myo::Myo::vibrationLong);
            return true;
        }
        return false;
    }

    float distance(float target[])
    {
        float pitch;
        float yaw;

        float dist = 100;

        for (int i=-1; i<=1; i++){
            pitch = pitch_w + 6.28*i;
            for (int j=-1; j<=1; j++){
                yaw = yaw_w + 6.28*i;
                dist = std::min (dist, static_cast<float>(sqrt((pitch - target[1]) * (pitch - target[1]) + (yaw - target[2]) * (yaw - target[2]))));
            }
        }

        return dist;
    }

    float absol(float n)
    {
        return n < 0 ? -n : n;
    }

    // These values are set by onArmRecognized() and onArmLost() above.
    bool onArm;
    myo::Arm whichArm;

    // These values are set by onOrientationData() and onPose() above.
    float roll_w, pitch_w, yaw_w;
    myo::Pose currentPose;

    float DISTANCE;
    int c;
    myo::Myo* myo;
};



int main(int argc, char** argv)
{
    bool win = true;
    float target [3] = {0, 0, 0};
    float LO [3] = {-1.57, -1.1, -3.14};
    float HI [3] = {1, 1.3, 3.14};

    // We catch any exceptions that might occur below -- see the catch statement for more details.
    try
    {

        // First, we create a Hub with our application identifier. Be sure not to use the com.example namespace when
        // publishing your application. The Hub provides access to one or more Myos.
        myo::Hub hub("com.example.hello-myo");

        std::cout << "Attempting to find a Myo..." << std::endl;

        // Next, we attempt to find a Myo to use. If a Myo is already paired in Myo Connect, this will return that Myo
        // immediately.
        // waitForAnyMyo() takes a timeout value in milliseconds. In this case we will try to find a Myo for 10 seconds, and
        // if that fails, the function will return a null pointer.
        myo::Myo* myo = hub.waitForMyo(10000);

        // If waitForAnyMyo() returned a null pointer, we failed to find a Myo, so exit with an error message.
        if (!myo)
        {
            throw std::runtime_error("Unable to find a Myo!");
        }

        // We've found a Myo.
        std::cout << "Connected to a Myo armband!" << std::endl << std::endl;

        // Next we construct an instance of our DeviceListener, so that we can register it with the Hub.
        DataCollector collector;

        // Hub::addListener() takes the address of any object whose class inherits from DeviceListener, and will cause
        // Hub::run() to send events to all registered device listeners.
        hub.addListener(&collector);

        collector.init(myo);
        // Finally we enter our main loop.
        while (1)
        {
            if (win)
            {
                for (int i=0; i<3; i++)
                {
                    target[i] = LO[i] + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(HI[i]-LO[i])));
                }
                win = false;
            }
            // In each iteration of our main loop, we run the Myo event loop for a set number of milliseconds.
            // In this case, we wish to update our display 20 times a second, so we run for 1000/20 milliseconds.
            hub.run(1000/20);
            // After processing events, we call the print() member function we defined above to print out the values we've
            // obtained from any events that have occurred.
            collector.loop(target);
            win = collector.isWin(target);
        }

        // If a standard exception occurred, we print out its message and exit.
    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
        std::cerr << "Press enter to continue.";
        std::cin.ignore();
        return 1;
    }
}
