.. highlight:: Objective-C

NeoPixel
========

NeoPixels are strands of LED with built-in drivers and are super simple to connect and program.

The `MBLNeopixel <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLNeopixel.html>`_ module allows you to create a `MBLNeopixelStrand <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLNeopixelStrand.html>`_ object which encapsulates all functionality.

Set Neopixel Colors
-------------------

This is how you would set the whole stand to green.

Note, if it lights up a color other than green, you have the wrong color ordering value.

::

    const int length = 30; // Specific to your NeoPixel stand
    const MBLColorOrdering color = MBLColorOrderingGRB; // Specific to your NeoPixel stand
    const MBLStrandSpeed speed = MBLStrandSpeedSlow; // Specific to your NeoPixel stand
        
    MBLNeopixelStrand *strand = [device.neopixel strandWithColor:color speed:speed pin:0 length:length];
    [strand initializeAsync];
    for (int i = 0; i < length; i++) {
        [strand setPixelAsync:i color:[UIColor greenColor]];
    }
    // ... some time later
    [strand clearAllPixelsAsync];
    [strand deinitializeAsync];

Rotate Strand
-------------

You can program a pattern and then rotate it for fun effects.

::

    const int length = 30; // Specific to your NeoPixel stand
    const MBLColorOrdering color = MBLColorOrderingGRB; // Specific to your NeoPixel stand
    const MBLStrandSpeed speed = MBLStrandSpeedSlow; // Specific to your NeoPixel stand
        
    MBLNeopixelStrand *strand = [device.neopixel strandWithColor:color speed:speed pin:0 length:length];
    for (int i = 0; i < length; i++) {
        UIColor *color;
        switch (i % 3) {
            case 0:
                color = [UIColor redColor];
                break;
            case 1:
                color = [UIColor greenColor];
                break;
            case 2:
                color = [UIColor blueColor];
                break;
        }
        [strand setPixelAsync:i color:color];
    }
    [strand rotateStrandWithDirectionAsync:MBLRotationDirectionAwayFromBoard repetitions:length period:100];

