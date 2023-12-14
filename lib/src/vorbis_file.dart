import "dart:ffi";
import "dart:typed_data";
import "package:ffi/ffi.dart";
import "./vorbisfile_generated_bindings.dart";

class VorbisFile {
  static const int bytesPerSample = 2;
  final VorbisfileBindings _bindings;
  late final Pointer<OggVorbis_File> _vfPointer;
  late final int channels;
  late final int rate;
  late final Uint8List data;

  VorbisFile(this._bindings, String path)
      : _vfPointer = calloc<OggVorbis_File>() {
    print("ov_fopen");
    Pointer<Utf8> cPath = path.toNativeUtf8();
    int error = _bindings.ov_fopen(cPath.cast<Char>(), _vfPointer);
    calloc.free(cPath);
    if (error != 0) {
      calloc.free(_vfPointer);
      throw ArgumentError("$path could not be opened.");
    }
    print("info");
    Pointer<vorbis_info> info = _bindings.ov_info(_vfPointer, -1);
    channels = info.ref.channels;
    rate = info.ref.rate;
    print("pcm_total");
    int lengthOfPCMSamples = _bindings.ov_pcm_total(_vfPointer, 0);
    int bufferSize = lengthOfPCMSamples * bytesPerSample * channels;
    Pointer<Int> bitstream = calloc<Int>();
    Pointer<Char> cBuffer = calloc<Char>(bufferSize);
    int index = 0;
    try {
      while (true) {
        int result = _bindings.ov_read(_vfPointer, cBuffer.elementAt(index),
            bufferSize - index, 0, bytesPerSample, 1, bitstream);
        print(result);
        if (result < 0) {
          throw StateError("Error decoding the ogg file");
        }
        if (result == 0) {
          break;
        }
        index += result;
      }
      data = Uint8List(bufferSize);
      for (int i = 0; i < data.length; i++) {
        data[i] = cBuffer[i];
      }
    } finally {
      calloc.free(bitstream);
      calloc.free(cBuffer);
      print("clearing");
      _bindings.ov_clear(_vfPointer);
      print("clear2");
      calloc.free(
          _vfPointer); // We have to manually clear that; ov_clear only clears its contents, it does not dialocate the struct.
    }
  }
}
