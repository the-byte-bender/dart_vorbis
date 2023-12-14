import "dart:ffi";
import "./vorbisfile_generated_bindings.dart";
import "./vorbis_file.dart";

class Vorbis {
  final VorbisfileBindings _bindings;
  Vorbis.fromDynamicLibrary(DynamicLibrary lib)
      : _bindings = VorbisfileBindings(lib);
  Vorbis(String vorbisfileLibraryPath)
      : this.fromDynamicLibrary(DynamicLibrary.open(vorbisfileLibraryPath));
  VorbisFile decodeFile(String path) => VorbisFile(_bindings, path);
}
