.. highlight:: swift

Timer
=====

The timer module, `MBLTimer <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLTimer.html>`_, allows you to create periodic events that trigger a certain number of times.

Periodic Event
--------------

Here is a simple way to buzz 3 times.

::

    let periodicEvent = device.timer?.event(withPeriod: 2000, eventCount: 3)
    periodicEvent?.programCommandsToRunOnEventAsync {
        device.hapticBuzzer?.startBuzzerAsync(pulseWidth: 500, completion: nil)
    }
