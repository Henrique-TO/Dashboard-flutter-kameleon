import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class FileService {
  Future<String> getUploadFolder() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory uploadDir = Directory('${appDir.path}/uploads');
    if (!await uploadDir.exists()) {
      await uploadDir.create(recursive: true);
    }
    return uploadDir.path;
  }

  Future<List<String>> pickImages() async {
  final picker = ImagePicker();
  final List<XFile> images = await picker.pickMultiImage();
  List<String> filenames = [];
  String uploadPath = await getUploadFolder();

  for (var image in images) {
    String filename = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    await File(image.path).copy('$uploadPath/$filename'); // Removida a variável newFile
    filenames.add(filename);
  }
  return filenames;
}

  Future<void> deleteImage(String filename) async {
    String uploadPath = await getUploadFolder();
    File file = File('$uploadPath/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }

  String addImagesToJson(String existingJson, List<String> newFilenames) {
    List<String> images = jsonDecode(existingJson).cast<String>();
    images.addAll(newFilenames);
    return jsonEncode(images);
  }

  String removeImageFromJson(String existingJson, String filename) {
    List<String> images = jsonDecode(existingJson).cast<String>();
    images.remove(filename);
    return jsonEncode(images);
  }
}