.. MetaWear iOS/macOS/tvOS API documentation master file, created by
   sphinx-quickstart on Sat Apr 16 02:20:42 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

MetaWear iOS/macOS/tvOS/watchOS API
===================================

The MetaWear iOS/macOS/tvOS/watchOS API provides a simple way to communicate with your MetaWear boards using Apple devices.  This is a thin wrapper around the `MetaWear C++ API <https://github.com/mbientlab/MetaWear-SDK-Cpp>`_ so you will find the `C++ documentation <https://mbientlab.com/cppdocs/latest/>`_ and `API reference <https://mbientlab.com/docs/metawear/cpp/latest/globals.html>`_ useful.  **This guide only covers the few Apple specific features added**.

If you are interested in the finer details of the library, see `source code <https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS>`_ and `API documentation <https://mbientlab.com/docs/metawear/ios/latest/>`_.

Getting Started
---------------

This guide assumes you have fundamental knowledge of iOS, macOS, or tvOS programming especially `Swift <https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/index.html>`_ and `Closures <https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html>`_.

If you are not developing for the Apple ecosystem, we also offer several `other API's <https://mbientlab.com/developers/>`_.

.. toctree::
    :hidden:
    :maxdepth: 1

    project_setup
    metawearboard
    metawearscanner
