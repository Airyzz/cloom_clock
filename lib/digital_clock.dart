// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:cloom_clock/widgets/animated_number.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'colors.dart';
import 'flare/assets_utils/dots_assets.dart';
import 'flare/assets_utils/numbers_assets.dart';

enum TypeLight { light, dark }

enum _Element { gradient, text, shadow, type }

final _lightTheme = {
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
  _Element.type: TypeLight.light,
  _Element.gradient: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cloom_primary_light, cloom_secondary_light],
    ),
  ),
};

final _darkTheme = {
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
  _Element.type: TypeLight.light,
  _Element.gradient: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cloom_primary_dark, cloom_secondary_dark],
    ),
  ),
};

/// A basic digital clock.
///
/// You can do better than this!
class CloomClock extends StatefulWidget {
  const CloomClock(this.model);

  final double numberWidth = 240;
  final double numberHeight = 350;

  final ClockModel model;

  static bool isEmbedded = false;

  // so it doesnt show previous number
  static double animationStartOffset = 1;

  @override
  _CloomClockState createState() => _CloomClockState();
}

class _CloomClockState extends State<CloomClock>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  DateTime _dateTime = DateTime.now();
  late Timer _timer;
  late FlareNumberAssets _flareAssets;
  // on the first frame, start the animation offset by this amount of time

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();

    controller = AnimationController(
      duration: Duration(minutes: 5),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(Duration(seconds: 1), () {
      CloomClock.animationStartOffset = 0;
    });
  }

  @override
  void didUpdateWidget(CloomClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    final assetsType =
        Theme.of(context).brightness == Brightness.light ? "light" : "dark";
    final assetDots = Theme.of(context).brightness == Brightness.light
        ? DotsAssets.light
        : DotsAssets.dark;

    _flareAssets = FlareNumberAssets(type: assetsType);

    // Get current time
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    // Parse times to integers
    int hourTens = int.parse(hour[0]); // X0:00
    int hourOnes = int.parse(hour[1]); // 0X:00
    int minuteTens = int.parse(minute[0]); // 00:X0
    int minuteOnes = int.parse(minute[1]); // 0X:0X

    // Get current controllers for each number
    FlareControllerEntry hourTensController =
        _flareAssets.getController(hourTens);
    FlareControllerEntry hourOnesController =
        _flareAssets.getController(hourOnes);
    FlareControllerEntry minuteTensController =
        _flareAssets.getController(minuteTens);
    FlareControllerEntry minuteOnesController =
        _flareAssets.getController(minuteOnes);

    // Draw
    return Container(
      decoration: colors[_Element.gradient] as Decoration,
      child: LayoutBuilder(builder: (context, constraints) {
        print(constraints.biggest);
        var numberHeight = constraints.biggest.height;
        var numberWidth = constraints.biggest.width / 3;

        var horizontalOffset1 = constraints.biggest.width / 25;
        var horizontalOffset2 = constraints.biggest.width / 7;
        var verticalOffset = constraints.biggest.height / 13;
        return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.scale(
                scale: lerpDouble(0.9, 1.0, controller.value),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    // -- Hour
                    Positioned(
                      left: -horizontalOffset1,
                      child: SwitchNumbers(
                        height: numberHeight,
                        width: numberWidth,
                        number: hourTensController,
                      ),
                    ),
                    // -- Hour
                    Positioned(
                      left: horizontalOffset2,
                      top: verticalOffset,
                      child: SwitchNumbers(
                        height: numberHeight,
                        width: numberWidth,
                        number: hourOnesController,
                      ),
                    ),
                    Center(
                      child: Container(
                        height: numberHeight,
                        width: numberWidth,
                        child: FlareActor(
                          assetDots,
                          animation: "loop",
                        ),
                      ),
                    ),
                    // -- Minutes
                    Positioned(
                      right: horizontalOffset2,
                      child: SwitchNumbers(
                        height: numberHeight,
                        width: numberWidth,
                        number: minuteTensController,
                      ),
                    ),
                    // -- Minutes
                    Positioned(
                      right: -horizontalOffset1,
                      top: verticalOffset,
                      child: SwitchNumbers(
                        number: minuteOnesController,
                        height: numberHeight,
                        width: numberWidth,
                      ),
                    )
                  ],
                ),
              );
            });
      }),
    );
  }
}
