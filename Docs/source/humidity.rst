.. highlight:: swift

Humidity
========

Electronic humidity sensors (hydrometer) measure humidity by measuring the capacitance or resistance of air samples.  This sensor comes packaged with the `BME280 <https://ae-bst.resource.bosch.com/media/_tech/media/datasheets/BST-BME280_DS001-11.pdf>`_ integrated environmental unit, only available on MetaEnvironment boards, and is accessible through the `MBLHygrometerBME280 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLHygrometerBME280.html>`_ interface.

To meet specific needs, different MetaWear models may have different hydrometers, so the ``MBLHygrometer`` class is actually a generic abstraction of all hydrometers.  You can up-cast to one of our derived hydrometer objects in order to access advanced features.


Cast to Derived Class
---------------------

There is currently nothing in the generic ``MBLHygrometer`` class, so you need to use the `MBLHygrometerBME280 <https://mbientlab.com/docs/metawear/ios/latest/Classes/MBLHygrometerBME280.html>`_ derived class.
::

    if let hygrometerBME280 = device.hygrometer as? MBLHygrometerBME280 {
    }
