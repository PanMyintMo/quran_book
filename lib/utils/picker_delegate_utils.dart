import 'dart:io';

import 'package:image_picker/image_picker.dart';

class PickerDelegateUtils {
  static Future<File?> takePhoto({bool isCamera = true}) async {
    if (isCamera) {}
    final ImagePicker imagePicker = ImagePicker();
    final XFile? photo = await imagePicker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    if (photo == null) {
      return null;
    }
    return File(photo.path);
  }
}
