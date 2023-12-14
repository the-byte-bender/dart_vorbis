import "dart:io";
import 'package:dart_vorbis/dart_vorbis.dart';

void main() {
  final Vorbis vorbis = Vorbis("vorbisfile.dll");
  final VorbisFile a = vorbis.decodeFile("./test.ogg");
  print(a.channels);
  print(a.rate);
  print(a.data.length);
  File("./test.pcm").writeAsBytesSync(a.data);
  print("Done");
}
