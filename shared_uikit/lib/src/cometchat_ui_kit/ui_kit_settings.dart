import '../../../cometchat_uikit_shared.dart';

///Used to set Ui kit level settings
class UIKitSettings {
  final String? appId;
  final String? region;
  final String? subscriptionType;
  final bool? autoEstablishSocketConnection;
  final String? authKey;
  final List<ExtensionsDataSource>? extensions;
  final ExtensionsDataSource? callingExtension;
  final String? adminHost;
  final String? clientHost;
  final List<String>? roles;
  final List<AIExtension>? aiFeature;
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  UIKitSettings._builder(UIKitSettingsBuilder builder)
      : appId = builder.appId,
        region = builder.region,
        subscriptionType = builder.subscriptionType,
        autoEstablishSocketConnection =
            builder.autoEstablishSocketConnection ?? true,
        authKey = builder.authKey,
        extensions = builder.extensions,
        callingExtension = builder.callingExtension,
        adminHost = builder.adminHost,
        clientHost = builder.clientHost,
        roles = builder.roles,
        aiFeature = builder.aiFeature,
        dateTimeFormatterCallback = builder.dateTimeFormatterCallback;
}

///Builder class for [UIKitSettings]
class UIKitSettingsBuilder {
  String? appId;
  String? region;
  String? subscriptionType;
  List<String>? roles;
  bool? autoEstablishSocketConnection;
  String? authKey;
  List<ExtensionsDataSource>? extensions;
  ExtensionsDataSource? callingExtension;
  String? adminHost;
  String? clientHost;
  List<AIExtension>? aiFeature;
  DateTimeFormatterCallback? dateTimeFormatterCallback;

  UIKitSettingsBuilder();

  UIKitSettings build() {
    return UIKitSettings._builder(this);
  }
}
