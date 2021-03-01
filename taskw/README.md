This Dart library serves two purposes. 

1. It acts as a wrapper around the small
[taskd-client-dart](https://github.com/bradyt/taskd-client-dart)
library, to implement a notion of storage of tasks together with a
method to synchronize those tasks with a Taskserver.
2. It also attempts to draw other non-Flutter-specific code out of the
Flutter `task` app, so for example we might have a focussed effort of
unit tests here.
