import 'dart:io';
import 'dart:typed_data';

class ImageFileModel {
  File file;
  Uint8List? uint8list;

  ImageFileModel(this.file, this.uint8list);
}
