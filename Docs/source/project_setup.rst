Project Setup
=============
Before you begin coding your app, you will need to add the MetaWear API to your project.  If you are new to Xcode and not familiar with CocoaPods we have povided an `app template <https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/tree/master/StarterProject>`_ that has taken care of all the steps outlined on this page.

Compile Dependency
------------------

.. highlight:: ruby

To add the MetaWear SDK as a dependency to your project you should setup `CocoaPods <https://guides.cocoapods.org/using/getting-started.html>`_, and add the following line to your Podfile:  ::

    pod "MetaWear"

.. highlight:: console

Then run:  ::

    pod install

Finding Your Device
-------------------

.. highlight:: swift

The last thing to do is retrieve an `MBLMetaWear <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLMetaWear.html>`_ object corresponding to your board by scanning for it.

::

    import MetaWear

    MBLMetaWearManager.shared().startScanForMetaWears() { array in
        // Hooray! We found a MetaWear board, so stop scanning for more
        MBLMetaWearManager.shared().stopScan()
        // Connect to the board we found
        if let device = array.first {
            device.connectAsync().success() { _ in
                // Hooray! We connected to a MetaWear board, so flash its LED!
                device.led?.flashColorAsync(UIColor.green, withIntensity: 0.5)
            }.failure() { error in
                // Sorry we couldn't connect
                print(error)
            }
        }
    }
