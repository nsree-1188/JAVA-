import 'dart:math';

void main() {
  double sinx = pi / 2;
  double siny = sin(sinx);
  print('sin(π/2) = $siny');

  double angleFromSin = asin(siny);
  print('asin(1.0) = $angleFromSin');

  double cosy = pi / 2;
  double cosx = cos(cosy);
  print('cos(π/2) = $cosx');

  double angleFromCos = acos(cosx);
  print('acos(0.0) = $angleFromCos');

  double tanz = pi / 4;
  double tanz1 = tan(tanz);
  print('tan(π/4) = $tanz1');

  double angleFromTan = atan(tanz1);
  print('atan(1.0) = $angleFromTan');
}
