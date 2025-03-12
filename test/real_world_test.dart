// import 'package:example_app/real_world.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   final platformVariant = ValueVariant<TargetPlatform>({
//     TargetPlatform.android,
//     TargetPlatform.iOS,
//   });
//
//   testWidgets(
//     'platform widget',
//     (tester) async {
//       final platform = platformVariant.currentValue!;
//
//       await tester.pumpWidget(
//         MaterialApp(
//           theme: ThemeData(
//             platform: platform,
//           ),
//           home: const PlatformWidget(),
//         ),
//       );
//
//       if (platform == TargetPlatform.android) {
//         expect(find.byType(AndroidWidget), findsOneWidget);
//         expect(find.byType(IosWidget), findsNothing);
//       } else {
//         expect(find.byType(IosWidget), findsOneWidget);
//         expect(find.byType(AndroidWidget), findsNothing);
//       }
//     },
//     variant: platformVariant,
//   );
// }
