import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:quizapp/parts/consts.dart';

/// permet d'uploader et supprimer
/// des fichiers photo / audio / vidéo
/// avec l'API de Cloudinary.

class FileUploader {
  static const _uploadPreset = "rvx2lyep";
  static const _cloudName = "dn1vcwy8m";
  static const _ressourceType = "auto";
  static const REQUEST_SUCCESSFUL = 200;
  static const REQUEST_FAILED = 404;
  
  Dio _dio = new Dio();

  /// upload un fichier avec une requete POST
  /// 
  /// INPUTS:
  /// 
  /// - file, un objet File qu'on veut uploader
  /// 
  /// - onUploadProgress, une fonction permettant
  /// de suivre et afficher/print la progression de l'upload
  /// 
  /// - onUploadDone, une fonction executée lorsque
  /// l'upload de fichier est successful.
  /// 
  /// OUTPUT:
  /// 
  /// - 
  /// 
  Future uploadFile(
      File file, Function onUploadProgress) async {
    try {
      var uploadUrl = _getRequestUploadUrl();
      var uploadData = await _getUploadData(file);

      Response _response = await _dio.post(
        uploadUrl,
        data: uploadData,
        onSendProgress: onUploadProgress,
      );

      return _response;

      
    } catch (e) {
      print("Oups.. pepin...");
      print(e);

      return NO_DATA;
    }
  }

  /// nous fournit l'url permettant
  /// un upload de fichier vers le cloud
  String _getRequestUploadUrl() {
    return "https://api.cloudinary.com/v1_1/$_cloudName/$_ressourceType/upload/";
  }

  /// les parametres de la requete HTTP d'upload (POST)
  _getUploadData(File file) async {
    return {
      "file": await _getBase64Uri(file),
      "upload_preset": _uploadPreset,
    };
  }

  _getBase64Uri(File file) async {
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
