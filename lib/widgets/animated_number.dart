// Copyright 2020 Filipe Barroso. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloom_clock/flare/assets_utils/numbers_assets.dart';
import 'package:cloom_clock/flare/number_flare_controller.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class SwitchNumbers extends StatelessWidget {
  final FlareControllerEntry number;
  final double height;
  final double width;
  final double animationStartOffset;

  SwitchNumbers({
    required this.number,
    required this.height,
    required this.width,
    this.animationStartOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: this.height,
        width: this.width,
        child: Stack(
          children: <Widget>[
            FlareActor(
              this.number.previous!.asset,
              controller: NumberFlareControler(
                  currentState: AnimationState.hide,
                  animationStartOffset: animationStartOffset),
            ),
            FlareActor(
              this.number.asset,
              controller: NumberFlareControler(
                  currentState: AnimationState.show,
                  animationStartOffset: animationStartOffset),
            )
          ],
        ));
  }
}
