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
const howManySubsteps = 4;

/// represente l'etape prendre une photo
const PRENDRE_PHOTO = 0;

/// represente l'etape MESSAGE AUDIO
const MSG_AUDIO = 1;

/// represente l'etape TEXTE OU EMOJI
const TEXTE_OU_EMOJI = 2;

/// represente l'etape enregistre sur internet
const ENREGISTRER = 3;