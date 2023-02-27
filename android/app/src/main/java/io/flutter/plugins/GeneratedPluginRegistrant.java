package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new com.example.appsettings.AppSettingsPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin app_settings, com.example.appsettings.AppSettingsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.customwebviewflutter.CustomWebViewFlutterPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin custom_webview, io.flutter.plugins.customwebviewflutter.CustomWebViewFlutterPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.deviceinfo.DeviceInfoPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin device_info, io.flutter.plugins.deviceinfo.DeviceInfoPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin device_info_plus, dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new co.creativemind.device_information.DeviceInformationPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin device_information, co.creativemind.device_information.DeviceInformationPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.mr.flutter.plugin.filepicker.FilePickerPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin file_picker, com.mr.flutter.plugin.filepicker.FilePickerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin firebase_auth, io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin firebase_core, io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin firebase_crashlytics, io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.database.FirebaseDatabasePlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin firebase_database, io.flutter.plugins.firebase.database.FirebaseDatabasePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin firebase_messaging, io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.amolg.flutterbarcodescanner.FlutterBarcodeScannerPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin flutter_barcode_scanner, com.amolg.flutterbarcodescanner.FlutterBarcodeScannerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin flutter_inappwebview, com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.endigo.plugins.pdfviewflutter.PDFViewFlutterPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin flutter_pdfview, io.endigo.plugins.pdfviewflutter.PDFViewFlutterPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin flutter_plugin_android_lifecycle, io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.example.fluttershare.FlutterSharePlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin flutter_share, com.example.fluttershare.FlutterSharePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin image_picker_android, io.flutter.plugins.imagepicker.ImagePickerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.flutter.plugins.integration_test.IntegrationTestPlugin());
    } catch(Exception e) {
      Log.e(TAG, "Error registering plugin integration_test, dev.flutter.plugins.integration_test.IntegrationTestPlugin", e);
    }
      try {
          flutterEngine.getPlugins().add(new io.flutter.plugins.nfcmanager.NfcManagerPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin nfc_manager, io.flutter.plugins.nfcmanager.NfcManagerPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin package_info_plus, dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new jp.espresso3389.pdf_render.PdfRenderPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin pdf_render, jp.espresso3389.pdf_render.PdfRenderPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new io.scer.pdfx.PdfxPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin pdfx, io.scer.pdfx.PdfxPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new gabrimatic.info.restart.RestartPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin restart_app, gabrimatic.info.restart.RestartPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin sqflite, com.tekartik.sqflite.SqflitePlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new com.syncfusion.flutter.pdfviewer.SyncfusionFlutterPdfViewerPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin syncfusion_flutter_pdfviewer, com.syncfusion.flutter.pdfviewer.SyncfusionFlutterPdfViewerPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin url_launcher_android, io.flutter.plugins.urllauncher.UrlLauncherPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new io.flutter.plugins.videoplayer.VideoPlayerPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin video_player_android, io.flutter.plugins.videoplayer.VideoPlayerPlugin", e);
      }
      try {
          flutterEngine.getPlugins().add(new io.flutter.plugins.webviewflutter.WebViewFlutterPlugin());
      } catch (Exception e) {
          Log.e(TAG, "Error registering plugin webview_flutter_android, io.flutter.plugins.webviewflutter.WebViewFlutterPlugin", e);
      }
  }
}
