import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

class StickerPainter extends CustomPainter {
  StickerPainter(this.mainImage, this.mainPeopleImage, this.peopleImages, this.peopleImagesByte);
  final ui.Image mainImage;
  final ui.Image mainPeopleImage;
  final List<Uint8List> peopleImagesByte;
  final List<ui.Image> peopleImages;

  var rng = new Random();

  ui.Image getRandomPeopleImage() {
    if (peopleImages.length < 1) {
      throw ("getRandomPeopleImage called when peopleImages is empty");
    }
    var number = rng.nextInt(peopleImages.length);
    print("rng = $number");
    return peopleImages[number];
  }

  Uint8List getRandomPeopleImageByte() {
    if (peopleImages.length < 1) {
      throw ("getRandomPeopleImage called when peopleImages is empty");
    }
    var number = rng.nextInt(peopleImages.length);
    print("rng = $number");
    return peopleImagesByte[number];
  }

  Canvas drawPeople(Canvas canvas, ui.Image peopleImage, Rect drawRect) {
    canvas.drawImageRect(
        peopleImage, getSizeRectSrc(peopleImage), drawRect, new Paint());
    return canvas;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // draw main image as background
    canvas.drawImage(mainImage, Offset.zero, Paint());

    // -------  START DRAW PEOPLE -----------
    print("peopleImage.length ${peopleImages.length}");
    if (peopleImages.length > 0) {
      // drawPeople(
      //   canvas,
      //   getRandomPeopleImage(),
      //   getSizeRect(500, 150, 0.5, mainImage),
      // );

      // drawPeople(
      //   canvas,
      //   getRandomPeopleImage(),
      //   getSizeRect(50, 150, 0.5, mainImage),
      // );

      // drawPeople(
      //   canvas,
      //   getRandomPeopleImage(),
      //   getSizeRect(1800, 150, 0.5, mainImage),
      // );

      // drawPeople(
      //   canvas,
      //   getRandomPeopleImage(),
      //   getSizeRect(-100, 100, 0.8, mainImage),
      // );
      final oriSize = getSizeRectSrc(mainImage);
      final oh = oriSize.height;
      final ow = oriSize.width;

      for (var i = 0.2; i < 0.8; i+=0.08) {
        final double scale = i;
        double cx = ow*(1-scale)/2.0;
        double cy = oh*(1-scale)/2.0;
        for (var j = -1; j < (1.5/scale); j++) { 
          drawPeople(
            canvas,
            getRandomPeopleImage(),
            getSizeRect(-(ow*scale)/2+(ow*scale)*j+rng.nextDouble()*(0.2*ow), cy-oh*0.11*i, scale, mainImage),
          );
        }     
      }
    }

    // -------  END DRAW PEOPLE -----------

    // draw main people on top at exact same position and size
    canvas.drawImageRect(mainPeopleImage, getSizeRectSrc(mainPeopleImage),
        getSizeRectSrc(mainImage), new Paint());
  }

  @override
  bool shouldRepaint(StickerPainter oldDelegate) {
    return peopleImages != oldDelegate.peopleImages;
  }

  Rect getSizeRectSrc(ui.Image src) {
    return Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble());
  }

  Rect getSizeRect(double x, double y, double scale, ui.Image src) {
    return Rect.fromLTWH(x, y, src.width * scale, src.height * scale);
  }
}
