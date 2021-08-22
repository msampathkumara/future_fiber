// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../platform_interface.dart';
import 'webview_method_channel.dart';

/// Builds an iOS webview.
///
/// This is used as the default implementation for [CustomWebView.platform] on iOS. It uses
/// a [UiKitView] to embed the webview in the widget hierarchy, and uses a method channel to
/// communicate with the platform code.
class CupertinoCustomWebView implements CustomWebViewPlatform {
  @override
  Widget build({
    required BuildContext context,
    required CreationParams creationParams,
    required CustomWebViewPlatformCallbacksHandler customWebViewPlatformCallbacksHandler,
    CustomWebViewPlatformCreatedCallback? onCustomWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return UiKitView(
      viewType: 'plugins.flutter.io/customwebview',
      onPlatformViewCreated: (int id) {
        if (onCustomWebViewPlatformCreated == null) {
          return;
        }
        onCustomWebViewPlatformCreated(
            MethodChannelCustomWebViewPlatform(id, customWebViewPlatformCallbacksHandler));
      },
      gestureRecognizers: gestureRecognizers,
      creationParams:
          MethodChannelCustomWebViewPlatform.creationParamsToMap(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  @override
  Future<bool> clearCookies() => MethodChannelCustomWebViewPlatform.clearCookies();
}
