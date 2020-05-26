# xdebug-protobuf-segfault

This repository demonstrates a segfault in xdebug when running inspecting instances of classes from the protobuf extension. The crash occurs in:

* Xdebug 2.9.5
* PHP 7.4.6, 7.3.18, and 7.2.31.
* Most versions of the Protobuf extension, including 3.12.1

## Usage

The demo script builds a docker image based on the official [PHP Docker Images](https://hub.docker.com/_/php).

To run the demo:

```
./run.sh
```

Or build a specific version of PHP, Xdebug, or Protobuf:

```
./run.sh -p 7.2.2 -x 2.9.4
```

## About

The protobug extension defines a message class that is the base class for many other protobuf types. 

1. This message class provides a `get_properties` handler that returns `NULL`: https://github.com/protocolbuffers/protobuf/blob/39d730dd96c81196893734ee1e075c34567e59ae/php/ext/google/protobuf/message.c#L255-L257
2. Xdebug's `xdebug_objdebug_pp()` relies on the `get_properties()` handler indirectly: https://github.com/xdebug/xdebug/blob/698d3c01cfec610a10beea0a33156fcdf37b1a72/src/lib/var.c#L53-L92
3. Many calls to `xdebug_objdebug_pp()` are followed by a null check, but `xdebug_var_export_text_ansi()` does not check for `NULL` before calling `xdebug_zend_hash_is_recursive()`: https://github.com/xdebug/xdebug/blob/00a928eb760833a07e01a7b17cc040e4f3a8a077/src/lib/var_export_text.c#L244-L250
4. The crash occurs in `xdebug_zend_hash_is_recursive()`

Ideally, extensions wouldn't return `NULL` from the `get_properties` handler, but that's impossible to prevent.
