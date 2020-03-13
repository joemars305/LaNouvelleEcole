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
  uploadFile(
      File file, Function onUploadProgress, onUploadDone) async {
    try {
      ///l'url et le form data de la request d'upload POST
      var uploadUrl = _getRequestUploadUrl();
      var uploadData = await _getUploadData(file);

      /// on lance une requete d'upload 
      /// et on attend le résultat
      Response _response = await _dio.post(
        uploadUrl,
        data: uploadData,
        onSendProgress: onUploadProgress,
      );

      /// l'objet recu en réponse
      var responseData = _response.data;

      /// le code de la réponse
      var responseCode = _response.statusCode;

      /// après avoir reçu la réponse de
      /// la requete,
      /// on run la fonction onUploadDone
      onUploadDone(responseData, responseCode);
      
    } catch (e) {
      print("Oups.. pepin...");
      print(e);

      return NO_DATA;
    }
  }

  close() {
    _dio.close();
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
