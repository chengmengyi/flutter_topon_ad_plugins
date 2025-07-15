import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_topon_ad_plugins_method_channel.dart';

abstract class FlutterToponAdPluginsPlatform extends PlatformInterface {
  /// Constructs a FlutterToponAdPluginsPlatform.
  FlutterToponAdPluginsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterToponAdPluginsPlatform _instance = MethodChannelFlutterToponAdPlugins();

  /// The default instance of [FlutterToponAdPluginsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterToponAdPlugins].
  static FlutterToponAdPluginsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterToponAdPluginsPlatform] when
  /// they register themselves.
  static set instance(FlutterToponAdPluginsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
