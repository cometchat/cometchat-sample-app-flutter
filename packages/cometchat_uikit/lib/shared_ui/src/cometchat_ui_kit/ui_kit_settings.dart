import '../../../shared_ui/cometchat_uikit_shared.dart';
import '../../../call_ui/src/calling_configuration.dart';

///Used to set Ui kit level settings
class UIKitSettings {
  final String? appId;
  final String? region;
  final String? subscriptionType;
  final bool? autoEstablishSocketConnection;
  final String? authKey;

  ///[enableCalls] when true, initializes the CometChat Calls SDK
  ///and registers the calling extension (call buttons, incoming/outgoing call screens, call message templates).
  ///Defaults to false.
  final bool enableCalls;

  ///[callingConfiguration] optional configuration for call buttons, incoming call, outgoing call, and group call settings.
  ///Only used when [enableCalls] is true.
  final CallingConfiguration? callingConfiguration;

  ///[enableThreadSubscription] feature gate for the thread follow/unfollow
  ///surfaces (the message action-sheet option and the threaded-header
  ///control). Defaults to false: with the gate off neither surface renders
  ///and no thread-subscription request is made, regardless of the individual
  ///visibility flags. There is no server-side capability signal, so this
  ///opt-in is the only control.
  final bool enableThreadSubscription;

  final String? adminHost;
  final String? clientHost;
  final List<String>? roles;
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  UIKitSettings._builder(UIKitSettingsBuilder builder)
    : appId = builder.appId,
      region = builder.region,
      subscriptionType = builder.subscriptionType,
      autoEstablishSocketConnection =
          builder.autoEstablishSocketConnection ?? true,
      authKey = builder.authKey,
      enableCalls = builder.enableCalls,
      callingConfiguration = builder.callingConfiguration,
      enableThreadSubscription = builder.enableThreadSubscription,
      adminHost = builder.adminHost,
      clientHost = builder.clientHost,
      roles = builder.roles,
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

  ///[enableCalls] when true, initializes the CometChat Calls SDK
  ///and registers the calling extension. Defaults to false.
  bool enableCalls = false;

  ///[callingConfiguration] optional configuration for call buttons, incoming call, outgoing call, and group call settings.
  ///Only used when [enableCalls] is true.
  CallingConfiguration? callingConfiguration;

  ///[enableThreadSubscription] feature gate for the thread follow/unfollow
  ///surfaces. Defaults to false (both surfaces stay hidden).
  bool enableThreadSubscription = false;

  String? adminHost;
  String? clientHost;
  DateTimeFormatterCallback? dateTimeFormatterCallback;

  UIKitSettingsBuilder();

  UIKitSettings build() {
    return UIKitSettings._builder(this);
  }
}
