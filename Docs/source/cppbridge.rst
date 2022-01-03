.. highlight:: swift

Bridge to CPP SDK
===================
As mentioned previously, the MetaWear iOS APIs are a wrapper around the CPP APIs.  ::

    import MetaWear
    import MetaWearCpp

The core libraries are written in C++ and many of the calls made are from the CPP library. You will find the `C++ documentation <https://mbientlab.com/cppdocs/latest/>`_ and `API reference <https://mbientlab.com/docs/metawear/cpp/latest/globals.html>`_ useful.

Bolts Swift
===================
`Bolts <https://github.com/BoltsFramework/Bolts-Swift>`_ is a collection of low-level libraries designed to make developing mobile apps easier. Bolts was designed by Parse and Facebook for our own internal use, and we have decided to open source these libraries to make them available to others.

We use Bolts swift in the iOS MetaWear API. ::

    import BoltsSwift  

Tasks
------
Bolts Tasks is a complete implementation of futures/promises for iOS/OS X/watchOS/tvOS and any platform that supports Swift.
A task represents the result of an asynchronous operation, which typically would be returned from a function.
In addition to being able to have different states `completed`/`faulted`/`cancelled` they provide these benefits:

    - `Tasks` consume fewer system resources, since they don't occupy a thread while waiting on other `Tasks`.
    - `Tasks` could be performed/chained in a row which will not create nested "pyramid" code as you would get when using only callbacks.
    - `Tasks` are fully composable, allowing you to perform branching, parallelism, and complex error handling, without the spaghetti code of having many named callbacks.
    - `Tasks` allow you to arrange code in the order that it executes, rather than having to split your logic across scattered callback functions.
    - `Tasks` don't depend on any particular threading model. So you can use concepts like operation queues/dispatch queues or even thread executors.
    - `Tasks` could be used synchronously or asynchronously, providing the same benefit of different results of any function/operation.

Chaining Tasks
---------------
There are special methods you can call on a task which accept a closure argument and will return the task object. Because they return tasks it means you can keep calling these methods – also known as _chaining_ – to perform logic in stages. This is a powerful approach that makes your code read as a sequence of steps, while harnessing the power of asynchronous execution. Here are 3 key functions you should know:

    1. Use `continueWith` to inspect the task after it has ran and perform more operations with the result
    2. Use `continueWithTask` to add more work based on the result of the previous task
    3. Use `continueOnSuccessWith` to perform logic only when task executed without errors

continueWith
^^^^^^^^^^^^^^^^^
Every `Task` has a function named `continueWith`, which takes a continuation closure. A continuation will be executed when the task is complete. You can the inspect the task to check if it was successful and to get its result.

::

    save(object).continueWith { task in
        if task.cancelled {
            // Save was cancelled
        } else if task.faulted {
            // Save failed
        } else {
            // Object was successfully saved
            let result = task.result
        }
    }

continueOnSuccessWith
^^^^^^^^^^^^^^^^^^^^^^
In many cases, you only want to do more work if the previous task was successful, and propagate any error or cancellation to be dealt with later. To do this, use `continueOnSuccessWith` function:

::

    save(object).continueOnSuccessWith { result in
        // Closure receives the result of a succesfully performed task
        // If result is invalid throw an error which will mark task as faulted
    }

Underneath, `continueOnSuccessWith` is calling `continueOnSuccessWithTask` method which is more powerful and useful for situations where you want to spawn additional work.

continueOnSuccessWithTask
^^^^^^^^^^^^^^^^^^^^^^^^^^
As you saw above, if you return an object from `continueWith` function – it will become a result the Task. But what if there is more work to do? If you want to call into more tasks and return their results instead – you can use `continueWithTask`. This gives you an ability to chain more asynchronous work together.

In the following example we want to fetch a user profile, then fetch a profile image, and if any of these operations failed - we still want to display an placeholder image:

::

    fetchProfile(user).continueOnSuccessWithTask { task in
        return fetchProfileImage(task.result);
    }.continueWith { task in
        if let image = task.result {
            return image
        }
        return ProfileImagePlaceholder()
    }
