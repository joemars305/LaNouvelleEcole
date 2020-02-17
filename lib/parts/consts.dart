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
const howManySubsteps = 5;

/// represente l'etape prendre une photo
const PRENDRE_PHOTO = 0;

/// represente l'etape MESSAGE AUDIO
const MSG_AUDIO = 1;

/// représente l'étape INVENTAIRE
const INVENTAIRE = 2;

/// represente l'etape TEXTE OU EMOJI
const TEXTE_OU_EMOJI = 3;

/// represente l'etape enregistre sur internet
const ENREGISTRER = 4;

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