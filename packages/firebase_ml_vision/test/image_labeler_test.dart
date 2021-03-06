// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseVision', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      FirebaseVision.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'ImageLabeler#processImage':
            return returnValue;
          default:
            return null;
        }
      });
      log.clear();
      FirebaseVision.nextHandle = 0;
    });

    group('$ImageLabeler', () {
      test('processImage', () async {
        final List<dynamic> labelData = <dynamic>[
          <dynamic, dynamic>{
            'confidence': 0.6,
            'entityId': 'hello',
            'text': 'friend',
          },
          <dynamic, dynamic>{
            'confidence': 0.8,
            'entityId': 'hi',
            'text': 'brother',
          },
          <dynamic, dynamic>{
            'confidence': 1,
            'entityId': 'hey',
            'text': 'sister',
          },
        ];

        returnValue = labelData;

        final ImageLabeler detector = FirebaseVision.instance.imageLabeler(
          const ImageLabelerOptions(confidenceThreshold: 0.2),
        );

        final FirebaseVisionImage image = FirebaseVisionImage.fromFilePath(
          'empty',
        );

        final List<ImageLabel> labels = await detector.processImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'ImageLabeler#processImage',
            arguments: <String, dynamic>{
              'handle': 0,
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'confidenceThreshold': 0.2,
              },
            },
          ),
        ]);

        expect(labels[0].confidence, 0.6);
        expect(labels[0].entityId, 'hello');
        expect(labels[0].text, 'friend');

        expect(labels[1].confidence, 0.8);
        expect(labels[1].entityId, 'hi');
        expect(labels[1].text, 'brother');

        expect(labels[2].confidence, 1.0);
        expect(labels[2].entityId, 'hey');
        expect(labels[2].text, 'sister');
      });

      test('processImage no blocks', () async {
        returnValue = <dynamic>[];

        final ImageLabeler detector = FirebaseVision.instance.imageLabeler(
          const ImageLabelerOptions(),
        );
        final FirebaseVisionImage image =
            FirebaseVisionImage.fromFilePath('empty');

        final List<ImageLabel> labels = await detector.processImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'ImageLabeler#processImage',
            arguments: <String, dynamic>{
              'handle': 0,
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'confidenceThreshold': 0.5,
              },
            },
          ),
        ]);

        expect(labels, isEmpty);
      });
    });
  });
}
