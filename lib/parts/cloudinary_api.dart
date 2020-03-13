import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';

/// permet d'uploader et supprimer
/// des fichiers photo / audio / vidéo
/// avec l'API de Cloudinary.

class FileUploader {
  Response response;
  Dio dio = new Dio();

  static const _uploadPreset = "rvx2lyep";
  static const _cloudName = "dn1vcwy8m";
  static const _ressourceType = "auto";

  /// upload un fichier
  uploadFile(File file) async {
    var uploadUrl = getRequestUploadUrl();
    var uploadData = await getUploadData(file);

    try {
      response = await dio.post(
        uploadUrl,
        data: uploadData,
        onSendProgress: (int sent, int total) {
          print("$sent $total");
        },
      );

      print('Statut réponse: ${response.statusCode}');
      print('body réponse: ${response.statusMessage}');
    } catch (e) {
      print("Oups.. pepin...");
      print(e);
    }
  }

  /// nous fournit l'url permettant
  /// un upload de fichier vers le cloud
  String getRequestUploadUrl() {
    return "https://api.cloudinary.com/v1_1/$_cloudName/$_ressourceType/upload/";
  }

  /// les parametres de la requete HTTP d'upload (POST)
  getUploadData(File file) async {
    return {
      "file": await getBase64Uri(file),
      "upload_preset": _uploadPreset,
    };
  }

  getBase64Uri(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    String filePath = file.path;
    String base64File = base64Encode(fileBytes);
    String mimeType = lookupMimeType(filePath);
    String base64Header = "data:" + mimeType + ";base64,";
    String fullBase64Uri = base64Header + base64File;

    print(base64Header);

    return fullBase64Uri;
  }
}
