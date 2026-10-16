import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'generated/news.pb.dart' as proto;

typedef NativeFetchC = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<Utf8> action,
  ffi.Pointer<ffi.Uint8> request,
  ffi.Int32 requestLength,
  ffi.Pointer<ffi.Int32> outLength,
);

typedef NativeFetchDart = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<Utf8> action,
  ffi.Pointer<ffi.Uint8> request,
  int requestLength,
  ffi.Pointer<ffi.Int32> outLength,
);

ffi.DynamicLibrary loadNativeLibrary() {
  final projectRoot = Directory.current.parent.path;
    final dylibPath = [
      projectRoot,
      'shared_core',
      'build',
      'bin',
      'macosX64',
      'debugShared',
      'libnews_core.dylib'
    ].join(Platform.pathSeparator);
    return ffi.DynamicLibrary.open(dylibPath);
}

class NewsBridge {
  late final NativeFetchDart _nativeFetch;

  NewsBridge() {
    final dylib = loadNativeLibrary();
    _nativeFetch = dylib
        .lookup<ffi.NativeFunction<NativeFetchC>>('native_fetch')
        .asFunction();
  }

  Future<proto.NewsResponse> fetchLiveNews({
    required int offset,
    required int limit,
  }) async {
    final ffi.Pointer<ffi.Int32> lengthPointer = calloc<ffi.Int32>();
    final ffi.Pointer<Utf8> actionPointer = 'get_news'.toNativeUtf8();

    final proto.NewsRequest requestParams = proto.NewsRequest()
      ..offset = offset
      ..limit = limit;
    final Uint8List requestBytes = requestParams.writeToBuffer();

    final ffi.Pointer<ffi.Uint8> requestPointer = calloc<ffi.Uint8>(
      requestBytes.length,
    );
    final Uint8List nativeView = requestPointer.asTypedList(
      requestBytes.length,
    );
    nativeView.setAll(0, requestBytes);

    try {
      final ffi.Pointer<ffi.Uint8> bytesPointer = _nativeFetch(
        actionPointer,
        requestPointer,
        requestBytes.length,
        lengthPointer,
      );

      final int bufferLength = lengthPointer.value;
      if (bufferLength == 0) return proto.NewsResponse()..totalCount = 0;

      final Uint8List protoBytes = bytesPointer.asTypedList(bufferLength);
      return proto.NewsResponse.fromBuffer(protoBytes);
    } finally {
      calloc.free(lengthPointer);
      calloc.free(actionPointer);
      calloc.free(requestPointer);
    }
  }
}