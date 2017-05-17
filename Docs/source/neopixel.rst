.. highlight:: swift

NeoPixel
========

NeoPixels are strands of LED with built-in drivers and are super simple to connect and program.

The `MBLNeopixel <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLNeopixel.html>`_ module allows you to create a `MBLNeopixelStrand <http://mbientlab.com/docs/metawear/ios/latest/Classes/MBLNeopixelStrand.html>`_ object which encapsulates all functionality.

Set Neopixel Colors
-------------------

This is how you would set the whole stand to green.

Note, if it lights up a color other than green, you have the wrong color ordering value.

::

    // All constants are specific to your NeoPixel stand
    let length: UInt8 = 30
    let strand = device.neopixel?.strand(withColor: .GBR, speed: .slow, pin: 0, length: length)
    strand?.initializeAsync()
    for i in 0..<length {
        strand?.setPixelAsync(i, color: .green)
    }
    // ... some time later
    strand?.clearAllPixelsAsync()
    strand?.deinitializeAsync()

Rotate Strand
-------------

You can program a pattern and then rotate it for fun effects.

::

    // All constants are specific to your NeoPixel stand
    let length: UInt8 = 30
    let strand = device.neopixel?.strand(withColor: .GBR, speed: .slow, pin: 0, length: length)
    strand?.initializeAsync()
    for i in 0..<length {
        switch i % 3 {
        case 0:
            strand?.setPixelAsync(i, color: .red)
        case 1:
            strand?.setPixelAsync(i, color: .green)
        default:
            strand?.setPixelAsync(i, color: .blue)
        }
    }
    strand?.rotateStrand(withDirectionAsync: .awayFromBoard, repetitions: length, period: 100)

