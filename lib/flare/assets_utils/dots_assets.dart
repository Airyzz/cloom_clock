// Copyright 2020 Filipe Barroso. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloom_clock/digital_clock.dart';

class DotsAssets {
  static String dark = (CloomClock.isEmbedded ? "packages/cloom_clock/" : "") +
      "assets/dark/dark_dots.flr";
  static String light = (CloomClock.isEmbedded ? "packages/cloom_clock/" : "") +
      "assets/light/light_dots.flr";
}
