import 'dart:math' as math;

void main() {
  whatToEatForLunch();
}

final lunch = ['Bread & Egg','Rice', 'Spaghetti', 'Snacks & Drinks'];

final dinner = ['Garri & Fish', 'Moimoi & Eko', 'Gala & Drinks'];


 void whatToEatForLunch(){
   int? pickedInt;
   String? pickedFood;

   pickedInt =  math.Random().nextInt(lunch.length);
   pickedFood = lunch[pickedInt];

   print(pickedFood);
 }

