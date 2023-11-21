import 'package:get/get.dart';

class LocalString extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'choose': 'Choose',
          'message': 'Choose Your Language',
          'changelang': 'Change Language'
        },
        'hi_IN': {
          'choose': 'स्वागत',
          'message': 'अपनी भाषा चुनें',
          'changelang': 'भाषा बदलें'
        },
        'lu_UG': {
          'choose': 'TUKWAANIRIZA londa',
          'message': 'Londa Olulimi Lwo',
          'changelang': 'Kyusa Olulimi'
        },
      };
}
