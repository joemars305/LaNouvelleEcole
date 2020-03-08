import 'package:flutter/material.dart';


/// PHOTO_SIZE représente la taille
/// de la photo de l'étape.
///
/// 0 pour NORMAL_SIZE
/// 1 pour FULL_SIZE
const int NORMAL_SIZE = 0;
const int FULL_SIZE = 1;

/// PHOTO_FILE représente la
/// photo de l'étape en cours.
///
/// null pour NO_PHOTO
/// File pour PHOTO
const NO_PHOTO = null;

/// CURRENT_TEXT représente le
/// texte à créer

///
/// null pour NO_TEXT
/// String pour TEXT
const NO_TEXT = null;

/// howManySubsteps est la quantité
/// de sous étapes à effectuer
const howManySubsteps = 7;
const lastStep = howManySubsteps - 1;

/// represente l'etape prendre une photo
const PRENDRE_PHOTO_VIDEO = 0;

/// représente l'étape text et emoji
//const TEXT_EMOJI = 2;
 
/// represente l'etape MESSAGE AUDIO
const MSG_AUDIO = 1;


/// représente l'étape INVENTAIRE
const INVENTAIRE = 2;

/// represente l'etape UPLOAD_PHOTO
const UPLOAD_FILES = 3;

/// represente les deux étapes finales,
/// ou nous prenons une photo du produit fini, 
/// puis on ajoute des infos approvisionnement
const PREND_THUMBNAIL_PHOTO = 4;
const COMPLETE_INVENTORY = 5;
const UPLOAD_THUMBNAIL = 6;

/// IS_RECORDING représente si on est en train, ou pas,
/// d'enregistrer un message audio
///
/// false pour NO_RECORD
/// true pour WE_RECORD
const NO_RECORD = false;
const WE_RECORD = true;

/// RECORDING représente le message audio
///
/// null pour NO_AUDIO_FILE
/// new Recording(...) pour AUDIO_FILE
const NO_AUDIO_FILE = null;

/// représente la durée maximale
/// d'un message audio d'étape
const DUREE_MSG_AUDIO = 15;

/// COUNTDOWN_VAL représente l'état d'avancement du
/// controller de l'animation compte à rebours
///
/// 1.0 pour BEGIN_ANIM
/// 0.0 pour END_ANIM
const BEGIN_ANIM = 1.0;
const END_ANIM = 0.0;

/*
void ...() {
  if (controller.value == BEGIN_ANIM) {
    beginAnim();
  }

  else if (controller.value == END_ANIM) {
    endAnim();
  }

  else {
    throw Error();
  }
}

void beginAnim() {

}

void endAnim() {

}
*/

/// PLAYER_STATE représente l'état du player audio
///
/// 0 pour STOPPED
/// 1 pour PLAYING
/// 2 pour PAUSED
const STOPPED = 0;
const PLAYING = 1;
const PAUSED = 2;

/// USER_INPUT_STRING représente
/// un futur texte provenant
/// de l'utilisateur
///
/// null pour NO_USER_INPUT
/// Future<''> pour EMPTY_USER_INPUT
/// Future<un String d'une lettre ou plus> pour le reste
const NO_USER_INPUT = null;
const EMPTY_USER_INPUT = "";

/// la taille des icones d'un objet
const ITEM_ICON_SIZE = 15.0;

/// la couleur des icones d'un objet
const ITEM_ICON_COLOR = Colors.white;

/// TXT_OU_EMOJI représente ce qu'on veut afficher
/// sur la photo d'étape
///
/// 0 pour DRAW_TEXT
/// 1 pour DRAW_EMOJI
const DRAW_TEXT = 0;
const DRAW_EMOJI = 1;

/// TEXTS_AND_EMOJIS représente le texte
/// et les émojis qu'on veut ajouter
/// sur notre photo pour expliquer des trucs
///
/// [] pour NO_TEXTS_AND_EMOJIS
/// List<DragBox> autrement

/// TAILLE DES ICONES DU BOTTOM BAR
const BOTTOM_ICON_SIZE = 30.0;

/// UPLOAD_TASK représente l"upload d'un fichier vers
/// le cloud Firebase
///
/// null pour NO_UPLOAD_TASK (pas d'upload en cours)
/// un StorageUploadTask autrement (un upload est en cours/pause/terminé)
const NO_UPLOAD_TASK = null;

/// UPLOAD_STATUS représente l'état actuel du
/// Uploader existant
///
/// 0 pour UP_IN_PROGRESS
/// 1 pour UP_PAUSED
/// 2 pour UP_COMPLETED

/*
fnForUpStatus() {
  if (_uploadTask.isInProgress) {
    return UP_IN_PROGRESS;
  }

  else if (_uploadTask.isPaused) {
    return UP_PAUSED;
  }

  else if (_uploadTask.isComplete) {
    return UP_COMPLETED;
  }
}
*/
const UP_IN_PROGRESS = 0;
const UP_PAUSED = 1;
const UP_COMPLETED = 2;

/// CREATE_UPLOAD représente si on demarre l'upload
///
/// false pour DONT_CREATE_UP
/// true pour CREATE_UP
const DONT_CREATE_UP = false;
const CREATE_UP = true;




/// PHOTO_PATH représente le chemin
/// vers la photo, dans firebase storage
/// 
/// null pour NO_PHOTO_PATH
/// String autrement
const NO_PHOTO_PATH = null;

/*
fnForPhotoPath(String photoPath) {
  if (_photoPath == NO_PHOTO_PATH) {
    return noPhotoPath();
  }

  else if (photoPath.length > 0) {

  }

  else {
    throw Error();
  }
}
*/

/// l'uri du storage bucket de firebase
const storageBucketUri = 'gs://la-nouvelle-ecole-7e29b.appspot.com';


/// PHOTO_URL représente
/// le moyen d'affichage de photo
/// via file ou via url
/// 
/// null pour NO_PHOTO_URL
/// String autrement

/*
photoUrl() {
  if (photoUrl == NO_PHOTO_URL) {
    return noUrl();
  }

  else if (photoUrl is String &&
           photoUrl.length > 0) {
    return url();
  }

  else {
    throw Error();
  }
}
*/
const NO_PHOTO_URL = null;

/// no data available
const NO_DATA = null;


const List<Widget> NO_TEXTS_AND_EMOJIS = [];

const int ADD_TEXT = 0;
const int ADD_EMOJI = 1;
const NO_FUTURE_CHOICE = null;

const SUPPRIME_ETAPE = 0;
const REMET_A_ZERO_ETAPE = 1;

const ETAP_SUIV = 0;
const FIN_LECON = 1;

const  NOT_MATURE = false;
const  MATURE = true;

 
// toutes les catégories de leçons disponibles
const NOURRITURE = 'Nourriture';
const LOGEMENT = 'Logement';
const ENERGIE = 'Energie';
const List<String> categories = [NOURRITURE, LOGEMENT, ENERGIE];

const PHOTO_FILE = 1;
const VIDEO_FILE = 0;
