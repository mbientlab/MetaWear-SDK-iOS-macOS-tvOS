.. highlight:: Objective-C

Timer
=====

The timer module, `MBLTimer <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLTimer.html>`_, allows you to create periodic events that trigger a certain number of times.

Periodic Event
--------------

Here is a simple way to buzz 3 times.

::

    MBLEvent *periodicEvent = [device.timer eventWithPeriod:2000 eventCount:3];
    [periodicEvent programCommandsToRunOnEventAsync:^{
        [device.hapticBuzzer startBuzzerWithPulseWidthAsync:500 completion:nil];
    }];

