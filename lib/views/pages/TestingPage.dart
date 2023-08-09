// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
//
// class TestingPage extends StatefulWidget {
//   TestingPage({
//     Key? key,
//     required this.images,
//   }) : super(key: key);
//
//   List<img.Image> images;
//
//   @override
//   State<TestingPage> createState() => _TestingPageState();
// }
//
// class _TestingPageState extends State<TestingPage> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     List<Widget> children = [];
//
//     for (int i=0; i<widget.images.length; i++) {
//       List<int>? imageWithHeader = img.encodeNamedImage(widget.images[i], ".bmp");
//       children.add(
//         Text('Image No: $i'),
//       );
//       children.add(
//         Container(
//           margin: const EdgeInsets.only(top: 100),
//           height: 150,
//           width: 200,
//           child: Image(
//             image: MemoryImage(
//               Uint8List.fromList(imageWithHeader!),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: children,
//         ),
//       ),
//     );
//   }
// }
