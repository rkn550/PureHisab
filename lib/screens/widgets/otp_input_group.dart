// import 'package:flutter/material.dart';
// import 'otp_input_field.dart';

// class OtpInputGroup extends StatelessWidget {
//   final List<TextEditingController> controllers;
//   final List<FocusNode> focusNodes;
//   final ValueChanged<String>? onChanged;
//   final String otpValue;
//   final double spacing;
//   final double fieldSize;
//   final double fontSize;

//   const OtpInputGroup({
//     super.key,
//     required this.controllers,
//     required this.focusNodes,
//     this.onChanged,
//     required this.otpValue,
//     this.spacing = 0,
//     this.fieldSize = 50,
//     this.fontSize = 24,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(controllers.length, (index) {
//         final isFilled = otpValue.length > index;
//         return OtpInputField(
//           controller: controllers[index],
//           focusNode: focusNodes[index],
//           index: index,
//           totalFields: controllers.length,
//           onChanged: (value) {
//             if (onChanged != null) {
//               onChanged!(value);
//             }
//           },
//           isFilled: isFilled,
//           size: fieldSize,
//           fontSize: fontSize,
//         );
//       }),
//     );
//   }
// }
