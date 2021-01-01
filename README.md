An attempt to write a taskserver client library in Dart, similar to
[taskd-client-py](https://github.com/jrabbit/taskd-client-py/).

As this project is in its early stages, you may find it helpful to
refer to the taskserver design documents, at
<https://taskwarrior.org/docs/design/index.html>.

# Tests

Run `make` or the following:

```sh
dart pub run test
```

But you will need a taskd server to pass all tests. There are several
ways to do this.

## macOS and GNU/Linux

```sh
cd fixture
dart pub get
dart setup.dart
make
```

## Windows

Open Debian in WSL in Terminal.exe.

Debian is recommended as their package manager provides taskd.

```sh
cd fixture
dart pub get
dart setup.dart
make
```

## Docker

```sh
cd docker
make
```
