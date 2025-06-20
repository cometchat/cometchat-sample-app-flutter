import 'dart:async';
import 'dart:io';

import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/src/utils/sdk_methods.dart';
import 'package:cometchat_uikit_shared/src/utils/timezone_utils/data/latest.dart';
import 'package:flutter/foundation.dart';

class CometChatUIKit {
  static UIKitSettings? authenticationSettings;

  static User? loggedInUser;

  static String localTimeZoneIdentifier = "";

  static String localTimeZoneName = "";

  static ConversationUpdateSettings? conversationUpdateSettings;

  /// method initializes the settings required for CometChat
  ///
  /// We suggest you call the init() method on app startup
  ///
  /// its necessary to first populate uiKitSettings inorder to call [init].
  static init(
      {required UIKitSettings uiKitSettings,
      Function(String successMessage)? onSuccess,
      Function(CometChatException e)? onError}) async {
    //if (!checkAuthSettings(onError)) return;
    authenticationSettings = uiKitSettings;
    AppSettings appSettings = (AppSettingsBuilder()
          ..subscriptionType = authenticationSettings?.subscriptionType ??
              CometChatSubscriptionType.allUsers
          ..region = authenticationSettings?.region
          ..autoEstablishSocketConnection =
              authenticationSettings?.autoEstablishSocketConnection ?? true
          ..adminHost = authenticationSettings?.adminHost
          ..clientHost = authenticationSettings?.clientHost)
        .build();

    await CometChat.init(authenticationSettings!.appId!, appSettings,
        onSuccess: (String successMessage) async {
      User? loggedInUser = await getLoggedInUser();
      if (loggedInUser != null) {
        CometChatUIKit.loggedInUser = loggedInUser;
        _initiateAfterLogin();
      }
      //executing custom onSuccess handler when CometChat SDK is initialized successfully
      getConversationUpdateSettings();
      if (onSuccess != null) {
        try {
          onSuccess(successMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "CometChat SDK is initialized successfully but failed to execute onSuccess callback");
          }
        }
      }

      CometChat.setSource(SetSourceConstant.uiKitVersion, Platform.operatingSystem, SetSourceConstant.platform);
    }, onError: (CometChatException exception) {
      //executing custom onError handler when CometChat SDK could not be initialized
      if (onError != null) {
        try {
          onError(exception);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "CometChat SDK could not be initialized and failed to execute onError callback");
          }
        }
      }
    });
  }

  /// Use this function only for testing purpose. For production, use [loginWithAuthToken]
  static Future<User?> login(String uid,
      {Function(User user)? onSuccess,
      Function(CometChatException excep)? onError}) async {
    if (!checkAuthSettings(onError)) return null;
    User? loggedInUser = await getLoggedInUser();

    if (loggedInUser == null || loggedInUser.uid != uid) {
      User? user = await CometChat.login(uid, authenticationSettings!.authKey!,
          onSuccess: (User user) {
        getConversationUpdateSettings();
        CometChatUIKit.loggedInUser = user;
        //executing custom onSuccess handler when user is logged in successfully
        if (onSuccess != null) {
          try {
            onSuccess(user);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  "user login is successful but failed to execute onSuccess callback");
            }
          }
        }

        _initiateAfterLogin();
      }, onError: onError);
      return user;
    } else {
      CometChatUIKit.loggedInUser = loggedInUser;
      getConversationUpdateSettings();
      if (onSuccess != null) {
        try {
          onSuccess(loggedInUser);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "user already logged in but failed to execute onSuccess callback");
          }
        }
      }

      _initiateAfterLogin();
      return loggedInUser;
    }
  }

  ///Returns a  [User] object after login in CometChat API.
  ///
  /// The CometChat SDK maintains the session of the logged in user within the SDK.
  /// Thus you do not need to call the login method for every session. You can use the
  /// CometChat.getLoggedInUser() method to check if there is any existing session in the SDK.
  /// This method should return the details of the logged-in user.
  ///
  /// [Create an Auth Token](https://www.cometchat.com/docs/chat-apis/ref#createauthtoken) via the CometChat API
  /// for the new user every time the user logs in to your app
  ///
  ///
  ///  method could throw [PlatformException] with error codes specifying the cause
  static Future<User?> loginWithAuthToken(String authToken,
      {Function(User user)? onSuccess,
      Function(CometChatException excep)? onError}) async {
    if (!checkAuthSettings(onError)) return null;
    User? loggedInUser = await getLoggedInUser();

    if (loggedInUser == null) {
      User? user =
          await CometChat.loginWithAuthToken(authToken, onSuccess: (User user) {
        //executing custom onSuccess handler when user is logged in successfully using auth token
        getConversationUpdateSettings();
        CometChatUIKit.loggedInUser = user;
        if (onSuccess != null) {
          try {
            onSuccess(user);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  "user login is successful but failed to execute onSuccess callback");
            }
          }
        }
        _initiateAfterLogin();
      }, onError: onError);
      return user;
    } else {
      CometChatUIKit.loggedInUser = loggedInUser;
      getConversationUpdateSettings();
      _initiateAfterLogin();
      return loggedInUser;
    }
  }

  static _initiateAfterLogin() {
    ChatConfigurator.init();
    _initializeSDKEVent();
    _inititalizeTimeZoneDetails();

    List<ExtensionsDataSource> extensionList =
        authenticationSettings?.extensions ?? [];

    List<ExtensionsDataSource> aiFeatureList =
        authenticationSettings?.aiFeature ?? [];
    // ?? DefaultExtensions.get();

    if (extensionList.isNotEmpty) {
      for (var element in extensionList) {
        element.enable();
      }
    }

    if (aiFeatureList.isNotEmpty) {
      for (var element in aiFeatureList) {
        element.enable();
      }
    }

    //enable calling extension if passed
    authenticationSettings?.callingExtension?.enable();

    initializeTimeZones();
  }

  static _initializeSDKEVent() {
    ChatSDKEventInitializer();
  }

  ///Method returns user after creation in cometchat environment
  ///
  /// Ideally, user creation should take place at your backend
  ///
  /// `uid` specified on user creation. Not editable after that.
  ///
  /// `name` Display name of the user.
  ///
  /// `avatar` URL to profile picture of the user.
  static Future<User?> createUser(User user,
      {Function(User user)? onSuccess,
      Function(CometChatException e)? onError}) async {
    if (!checkAuthSettings(onError)) return null;

    User? resultUser;

    resultUser = await CometChat.createUser(
        user, authenticationSettings!.authKey!,
        onSuccess: onSuccess, onError: onError);
    return resultUser;
  }

  ///Updating a user similar to creating a user should ideally be achieved at your backend using the Restful APIs
  ///
  /// [user] a user object which user needs to be updated.
  ///
  /// method could throw `PlatformException` with error codes specifying the cause
  static Future<User?> updateUser(User user,
      {Function(User retUser)? onSuccess,
      Function(CometChatException excep)? onError}) async {
    if (!checkAuthSettings(onError)) return null;

    User? user0;

    user0 = await CometChat.updateUser(user, authenticationSettings!.authKey!,
        onSuccess: onSuccess, onError: onError);

    return user0;
  }

  ///used to logout user
  ///
  /// method could throw [PlatformException] with error codes specifying the cause
  static logout(
      {dynamic Function(String)? onSuccess,
      Function(CometChatException excep)? onError}) async {
    if (!checkAuthSettings(onError)) return;
    await CometChat.logout(
      onSuccess: (message) {
        CometChatUIKit.loggedInUser = null;
        if (onSuccess != null) {
          try {
            onSuccess(message);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  'user logout was successful: $message, but unable to execute custom onSuccess callback');
            }
          }
        }
      },
      onError: (error) {
        if (onError != null) {
          try {
            onError(error);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  'user logout was unsuccessful: ${error.message}, but unable to execute custom onError callback');
            }
          }
        }
      },
    );
    ChatConfigurator.init();
  }

  static bool checkAuthSettings(Function(CometChatException e)? onError) {
    if (authenticationSettings == null) {
      if (onError != null) {
        onError(CometChatException("ERR", "Authentication null",
            "Populate uiKitSettings before initializing"));
      }
      return false;
    }

    if (authenticationSettings!.appId == null) {
      if (onError != null) {
        onError(CometChatException("appIdErr", "APP ID null",
            "Populate appId in uiKitSettings before initializing"));
      }
      return false;
    }
    return true;
  }

  //---------- Helper methods to send messages ----------
  ///[sendCustomMessage] used to send a custom message
  static Future<CustomMessage?> sendCustomMessage(
    CustomMessage message, {
    dynamic Function(CustomMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }

    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);
    CustomMessage? result = await CometChat.sendCustomMessage(message,
        onSuccess: (CustomMessage sentMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(sentMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message sent successfully but failed to execute onSuccess callback");
          }
        }
      }
      //the ccMessageSent event is emitted to update the message receipt shown
      //in the footer of the message bubble from in progress to sent
      CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message could not be sent and failed to execute onError callback");
          }
        }
      }
      //a error property is added to the metadata of the message
      //because of which a error message receipt will be shown in the
      //footer of the message bubble in the message list
      if (message.metadata != null) {
        message.metadata!["error"] = error;
      } else {
        message.metadata = {"error": error};
      }
      CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
    });
    return result;
  }

  ///[sendTextMessage] used to send a text message
  static Future<TextMessage?> sendTextMessage(
    TextMessage message, {
    dynamic Function(TextMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }
    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);
    TextMessage? result = await CometChat.sendMessage(message,
        onSuccess: (TextMessage sentMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(sentMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message sent successfully but failed to execute onSuccess callback");
          }
        }
      }
      //the ccMessageSent event is emitted to update the message receipt shown
      //in the footer of the message bubble from in progress to sent
      CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message could not be sent and failed to execute onError callback");
          }
        }
      }
      //a error property is added to the metadata of the message
      //because of which a error message receipt will be shown in the
      //footer of the message bubble in the message list
      if (message.metadata != null) {
        message.metadata!["error"] = error;
      } else {
        message.metadata = {"error": error};
      }
      CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
    });
    return result;
  }

  ///[sendMediaMessage] used to send a media message
  static Future<MediaMessage?> sendMediaMessage(MediaMessage message,
      {dynamic Function(MediaMessage)? onSuccess,
      dynamic Function(CometChatException)? onError,
      bool replacePathForIOS = true}) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }

    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);

    MediaMessage? mediaMessage2;

    if (replacePathForIOS == true) {
      //for sending files
      mediaMessage2 = MediaMessage(
        receiverType: message.receiverType,
        type: message.type,
        receiverUid: message.receiverUid,
        file: (Platform.isIOS &&
                message.file != null &&
                (!message.file!.startsWith('file://')))
            ? 'file://${message.file}'
            : message.file,
        metadata: message.metadata,
        sender: message.sender,
        parentMessageId: message.parentMessageId,
        muid: message.muid,
        category: message.category,
        attachment: message.attachment,
        caption: message.caption,
        tags: message.tags,
      );
    }

    MediaMessage? result = await CometChat.sendMediaMessage(
        mediaMessage2 ?? message, onSuccess: (MediaMessage sentMessage) {
      //executing the custom onSuccess handler

      if (replacePathForIOS == true) {
        if (Platform.isIOS) {
          if (message.file != null) {
            sentMessage.file = message.file?.replaceAll("file://", '');
          }
        } else {
          sentMessage.file = message.file;
        }
      }

      if (onSuccess != null) {
        try {
          onSuccess(sentMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message sent successfully but failed to execute onSuccess callback");
          }
        }
      }
      //the ccMessageSent event is emitted to update the message receipt shown
      //in the footer of the message bubble from in progress to sent
      CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message could not be sent and failed to execute onError callback");
          }
        }
      }
      //a error property is added to the metadata of the message
      //because of which a error message receipt will be shown in the
      //footer of the message bubble in the message list
      if (message.metadata != null) {
        message.metadata!["error"] = error;
      } else {
        message.metadata = {"error": error};
      }
      CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
    });
    return result;
  }

  ///[sendFormMessage] used to send a custom message
  static Future<FormMessage?> sendFormMessage(
    FormMessage message, {
    dynamic Function(FormMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }

    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);
    FormMessage? result = await SDKMethods.sendFormMessage(message,
        onSuccess: (FormMessage sentMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(sentMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message sent successfully but failed to execute onSuccess callback");
          }
        }
      }
      //the ccMessageSent event is emitted to update the message receipt shown
      //in the footer of the message bubble from in progress to sent
      CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message could not be sent and failed to execute onError callback");
          }
        }
      }
      //a error property is added to the metadata of the message
      //because of which a error message receipt will be shown in the
      //footer of the message bubble in the message list
      if (message.metadata != null) {
        message.metadata!["error"] = error;
      } else {
        message.metadata = {"error": error};
      }
      CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
    });
    return result;
  }

  ///[sendFormMessage] used to send a custom message
  static Future<CardMessage?> sendCardMessage(
    CardMessage message, {
    dynamic Function(CardMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }

    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);
    CardMessage? result = await SDKMethods.sendCardMessage(message,
        onSuccess: (CardMessage sentMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(sentMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message sent successfully but failed to execute onSuccess callback");
          }
        }
      }
      //the ccMessageSent event is emitted to update the message receipt shown
      //in the footer of the message bubble from in progress to sent
      CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message could not be sent and failed to execute onError callback");
          }
        }
      }
      //a error property is added to the metadata of the message
      //because of which a error message receipt will be shown in the
      //footer of the message bubble in the message list
      if (message.metadata != null) {
        message.metadata!["error"] = error;
      } else {
        message.metadata = {"error": error};
      }
      CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
    });
    return result;
  }

  ///[SchedulerMessage] used to send a custom message
  static Future<SchedulerMessage?> sendSchedulerMessage(
    SchedulerMessage message, {
    dynamic Function(SchedulerMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }

    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);
    SchedulerMessage? result = await SDKMethods.sendSchedulerMessage(message,
        onSuccess: (SchedulerMessage sentMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(sentMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message sent successfully but failed to execute onSuccess callback");
          }
        }
      }
      //the ccMessageSent event is emitted to update the message receipt shown
      //in the footer of the message bubble from in progress to sent
      CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                "message could not be sent and failed to execute onError callback");
          }
        }
      }
      //a error property is added to the metadata of the message
      //because of which a error message receipt will be shown in the
      //footer of the message bubble in the message list
      if (message.metadata != null) {
        message.metadata!["error"] = error;
      } else {
        message.metadata = {"error": error};
      }
      CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
    });
    return result;
  }

  ///[getLoggedInUser] checks if any session is active and retrieves the [User] data of the logged in user
  static Future<User?> getLoggedInUser(
      {dynamic Function(User)? onSuccess,
      dynamic Function(CometChatException)? onError}) async {
    User? user = await CometChat.getLoggedInUser(onSuccess: (user) {
      CometChatUIKit.loggedInUser = user;

      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(user);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("failed to execute onSuccess callback");
          }
        }
      }
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("failed to execute onError callback");
          }
        }
      }
    });
    return user;
  }

  /// method used to get decorated data source which contains all the extensions logic
  ///
  /// to get the latest logic for extensions
  /// ```
  ///[CometChatUIKit.getDataSource()]
  /// ```
  static DataSource getDataSource() {
    return ChatConfigurator.getDataSource();
  }

  ///[soundManager] used to play sound
  static final SoundManager soundManager = SoundManager();

  static _inititalizeTimeZoneDetails() {
    try {
      String currentTimeZone = DateTime.now().timeZoneName;
      Map<String, Map> timeZones = SchedulerUtils.timeZones;
      timeZones.removeWhere((key, value) {
        if (value["sabbr"] != null && value["sabbr"] == currentTimeZone) {
          return false;
        } else if (value["abbr"] == currentTimeZone) {
          return false;
        }
        return true;
      });
      localTimeZoneIdentifier = timeZones.keys.first;
      localTimeZoneName = timeZones.values.first["name"];
    } catch (e) {
      if (kDebugMode) {
        debugPrint("failed to initialize timezone details ${e.toString()}");
      }
    }
  }

  ///[addReaction] will add a reaction to a message with the provided message ID and will update the UI of `CometChatMessageList` and `CometChatReactions` accordingly

  static Future<BaseMessage?> addReaction(
    int messageId,
    String reaction, {
    dynamic Function(BaseMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    final message = await CometChat.addReaction(messageId, reaction,
        onSuccess: (reactedMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(reactedMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("failed to execute onSuccess callback");
          }
        }
      }

      CometChatMessageEvents.ccMessageEdited(
          reactedMessage, MessageEditStatus.success);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("failed to execute onError callback");
          }
        }
      }
    });

    return message;
  }

  ///[addReaction] will remove a reaction to a message with the provided message ID and will update the UI of [CometChatMessageList] and [CometChatReactions] accordingly
  static Future<BaseMessage?> removeReaction(
    int messageId,
    String reaction, {
    dynamic Function(BaseMessage)? onSuccess,
    dynamic Function(CometChatException)? onError,
  }) async {
    final message = await CometChat.removeReaction(messageId, reaction,
        onSuccess: (reactedMessage) {
      //executing the custom onSuccess handler
      if (onSuccess != null) {
        try {
          onSuccess(reactedMessage);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("failed to execute onSuccess callback");
          }
        }
      }

      CometChatMessageEvents.ccMessageEdited(
          reactedMessage, MessageEditStatus.success);
    }, onError: (error) {
      //executing the custom onError handler
      if (onError != null) {
        try {
          onError(error);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("failed to execute onError callback");
          }
        }
      }
    });

    return message;
  }

  static void getConversationUpdateSettings() async {
    await CometChat.getConversationUpdateSettings(
      onSuccess: (settings) {
        conversationUpdateSettings = settings;
      },
      onError: (exception) {
        if (kDebugMode) {
          debugPrint(
              "Cannot get conversation update settings ${exception.message}");
        }
      },
    );
  }

  ///[sendCustomInteractiveMessage] can be used to send a custom interactive message
  static Future<InteractiveMessage?> sendCustomInteractiveMessage(
      InteractiveMessage message, {
        dynamic Function(InteractiveMessage)? onSuccess,
        dynamic Function(CometChatException)? onError,
      }) async {
    if (message.parentMessageId == -1) {
      message.parentMessageId = 0;
    }

    message.sender ??= loggedInUser;
    if (message.muid.trim().isEmpty) {
      message.muid = DateTime.now().microsecondsSinceEpoch.toString();
    }

    CometChatMessageEvents.ccMessageSent(message, MessageStatus.inProgress);

    InteractiveMessage? result = await CometChat.sendInteractiveMessage(message,
        onSuccess: (InteractiveMessage sentMessage) {
          //executing the custom onSuccess handler
          if (onSuccess != null) {
            try {
              onSuccess(sentMessage);
            } catch (e) {
              if (kDebugMode) {
                debugPrint(
                    "message sent successfully but failed to execute onSuccess callback");
              }
            }
          }
          //the ccMessageSent event is emitted to update the message receipt shown
          //in the footer of the message bubble from in progress to sent
          CometChatMessageEvents.ccMessageSent(sentMessage, MessageStatus.sent);
        }, onError: (error) {
          //executing the custom onError handler
          if (onError != null) {
            try {
              onError(error);
            } catch (e) {
              if (kDebugMode) {
                debugPrint(
                    "message could not be sent and failed to execute onError callback");
              }
            }
          }
          //a error property is added to the metadata of the message
          //because of which a error message receipt will be shown in the
          //footer of the message bubble in the message list
          if (message.metadata != null) {
            message.metadata!["error"] = error;
          } else {
            message.metadata = {"error": error};
          }
          CometChatMessageEvents.ccMessageSent(message, MessageStatus.error);
        });
    return result;
  }
}
