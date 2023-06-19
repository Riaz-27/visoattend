import 'dart:ui';
import 'package:image/image.dart' as img;

import 'user_model.dart';

class RecognitionModel {
  dynamic userOrNot; // UserModel or String .. String if the face is unknown
  double distance;
  Rect position;
  img.Image? face;

  RecognitionModel({
    required this.userOrNot,
    required this.distance,
    required this.position,
    this.face,
  });

  // @override
  // bool operator ==(Object other) =>
  //     other is RecognitionModel &&
  //     userOrNot is UserModel &&
  //     userOrNot.authUid == other.userOrNot.authUid;
  //
  // @override
  // int get hashCode => Object.hash(userOrNot, 'Uk');
}
