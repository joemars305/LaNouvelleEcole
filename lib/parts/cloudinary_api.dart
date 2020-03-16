import 'dart:io';
//import 'dart:convert';
//import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:quizapp/parts/consts.dart';
import 'package:http/http.dart' as http;

/// permet d'uploader et supprimer
/// des fichiers photo / audio / vidéo
/// avec l'API de Cloudinary.

class FileUploader {
  /*static const _uploadPreset = "rvx2lyep";
  static const _cloudName = "dn1vcwy8m";
  static const _ressourceType = "auto";
  static const _apiKey = "316872425568417";
  static const _apiSecret = "0k-azq69LgAx3rkUpcBOK8LO_lY";*/
  
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
      //var uploadData = await _getUploadData(file);

      /// on lance une requete d'upload 
      /// et on attend le résultat
      http.Response _response = await http.put(
        uploadUrl,
        headers: {
          'Checksum': '',
        },
        
        body: file.readAsBytesSync().toString(),
      );

      /// l'objet recu en réponse
      var responseData = _response.body;

      /// le code de la réponse
      var responseCode = _response.statusCode;

      print("data:  $responseData");
      print("code:  $responseCode");
      
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
    return "https://storage.bunnycdn.com/lanouvelleecole/testons/test.png";
  }

  /// les parametres de la requete HTTP d'upload (POST)
  /*_getUploadData(File file) async {
    return json.encode({

    });
  }*/

  /*_getBase64Uri(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    String filePath = file.path;
    String base64File = base64Encode(fileBytes);
    String mimeType = lookupMimeType(filePath);
    String base64Header = "data:" + mimeType + ";base64,";
    String fullBase64Uri = base64Header + base64File;

    print(base64Header);

    return fullBase64Uri;
  }*/


  /// delete un fichier avec une requete POST
  /// 
  /// INPUTS:
  /// 
  /// - publicId, un String permettant de supprimer le fichier
  /// dans le cloud
  /// 
  /// OUTPUT:
  /// 
  /// - 
  /// 
  deleteFile(String publicId, Function onDeleteDone) async {
    try {
      ///l'url et le form data de la request d'upload POST
      var deleteUrl = _getRequestDeleteUrl();
      var deleteData = _getRequestDeleteData(publicId);

     

      /// on lance une requete d'upload 
      /// et on attend le résultat
      Response _response = await _dio.post(
        deleteUrl,
        data: deleteData,
      );

      print("cacatus");

      /// l'objet recu en réponse
      var responseData = _response.data;

      /// le code de la réponse
      var responseCode = _response.statusCode;

      

      /// après avoir reçu la réponse de
      /// la requete,
      /// on run la fonction onUploadDone
      onDeleteDone(responseData, responseCode);
      
    } on DioError catch (e) {
      print("Oups.. pepine...");
      print(e);

      return NO_DATA;
    }
  }

  /// nous fournit l'url permettant
  /// un upload de fichier vers le cloud
  String _getRequestDeleteUrl() {
    return "";//"https://api.cloudinary.com/v1_1/$_cloudName/$_ressourceType/destroy";
  }

  /// les parametres de la requete HTTP d'upload (POST)
  _getRequestDeleteData(String publicId)  {
    return {
      "public_id": publicId,
    };
  }
}
