/// The `cometchat_uikit_shared` library.
///
/// This library provides shared utilities for the CometChat UIKit. It consolidates
/// various resources, constants, events, utilities, and views required for
/// CometChat to function.

library cometchat_uikit_shared;

export 'package:cometchat_sdk/cometchat_sdk.dart';

export 'l10n/translations.dart';
export 'l10n/translations_ar.dart';
export 'l10n/translations_de.dart';
export 'l10n/translations_en.dart';
export 'l10n/translations_es.dart';
export 'l10n/translations_fr.dart';
export 'l10n/translations_hi.dart';
export 'l10n/translations_hu.dart';
export 'l10n/translations_ja.dart';
export 'l10n/translations_ko.dart';
export 'l10n/translations_lt.dart';
export 'l10n/translations_ms.dart';
export 'l10n/translations_nl.dart';
export 'l10n/translations_pt.dart';
export 'l10n/translations_ru.dart';
export 'l10n/translations_sv.dart';
export 'l10n/translations_tr.dart';
export 'l10n/translations_zh.dart';
export 'l10n/translations_en_GB.dart';

export 'src/models/cometchat_message_template.dart';

export 'src/models/cometchat_message_option.dart';
export 'src/models/cometchat_message_composer_action.dart';

// ------------------ shared -------------------

//---constants---
export 'src/constants/ui_kit_constants.dart';
export 'src/constants/asset_constants.dart';
export 'src/constants/enums.dart';
export 'src/constants/regex_constants.dart';
export 'src/constants/request_builder_constants.dart';

//---events---
export 'src/events/user_events/cometchat_user_event_listener.dart';
export 'src/events/user_events/cometchat_user_events.dart';

export 'src/events/group_events/cometchat_group_events.dart';
export 'src/events/group_events/cometchat_group_event_listener.dart';

export 'src/events/conversation_events/cometchat_conversation_event_listener.dart';
export 'src/events/conversation_events/cometchat_conversation_events.dart';

export 'src/events/message_events/cometchat_message_event_listener.dart';
export 'src/events/message_events/cometchat_message_events.dart';

export 'src/events/ui_events/cometchat_ui_event_listener.dart';
export 'src/events/ui_events/cometchat_ui_events.dart';


export 'src/events/call_events/cometchat_call_events.dart';
export 'src/events/call_events/cometchat_call_event_listener.dart';

export 'src/events/ai_assistant_events/cometchat_ai_assistant_events.dart';
export 'src/events/ai_assistant_events/cometchat_ai_assistant_events_listener.dart';

//---helpers---
export 'src/cometchat_ui_kit/ui_kit_settings.dart';
export 'src/cometchat_ui_kit/cometchat_ui_kit_helper.dart';
export 'src/cometchat_ui_kit/cometchat_ui_kit.dart';

//---models---
export 'src/models/cometchat_details_template.dart';
export 'src/models/action_item.dart';
export 'src/models/base_styles.dart';
export 'src/models/cometchat_base_options.dart';
export 'src/models/cometchat_option.dart';
export 'src/models/cometchat_details_option.dart';
export 'src/models/cometchat_group_member_option.dart';
export 'src/models/cometchat_user_option.dart';

//---resources---
export 'src/resources/sound_manager.dart';

//---utils---
export 'src/utils/message_receipt_utils.dart';
export 'src/utils/conversation_utils.dart';
export 'src/utils/detail_utils.dart';
export 'src/utils/message_utils.dart';
export 'src/utils/ui_event_utils.dart';
export 'src/framework/messages_data_source.dart';
export 'src/utils/file_utils.dart';
export 'src/utils/string_utils.dart';
export 'src/utils/widget_position_util.dart';
export 'src/utils/ai_constants.dart';
export 'src/utils/ai_utils.dart';
export 'src/utils/moderation_check_util.dart';
export 'src/utils/text_marquee_effect.dart';

//---views---
//cometchat badge
export 'src/views/badge/cometchat_badge.dart';
export 'src/views/badge/cometchat_badge_style.dart';
// cometchat status indicator
export 'src/views/status_indicator/cometchat_status_indicator.dart';
export 'src/views/status_indicator/cometchat_status_indicator_style.dart';
//cometchat date
export 'src/views/date/cometchat_date.dart';
export 'src/views/date/cometchat_date_style.dart';

//cometchat avatar
export 'src/views/avatar/cometchat_avatar.dart';
export 'src/views/avatar/cometchat_avatar_style.dart';

//cometchat listbase
export 'src/views/listbase/cometchat_listbase.dart';
export 'src/views/listbase/listbase_style.dart';

//cometchat listitem
export 'src/views/list_item/cometchat_list_item.dart';
export 'src/views/list_item/list_item_style.dart';
export 'src/views/list_item/swipe_tile.dart';

//message Bubble
export 'src/views/message_bubble/cometchat_message_bubble_style.dart';
export 'src/views/message_bubble/cometchat_message_bubble.dart';

//text bubble
export 'src/views/text_bubble/cometchat_text_bubble.dart';
export 'src/views/text_bubble/cometchat_text_bubble_style.dart';

//image bubble
export 'src/views/image_bubble/cometchat_image_bubble.dart';
export 'src/views/image_bubble/cometchat_image_bubble_style.dart';
export 'src/views/image_bubble/image_viewer.dart';

//video bubble
export 'src/views/video_bubble/cometchat_video_bubble.dart';
export 'src/views/video_bubble/cometchat_video_bubble_style.dart';
export 'src/views/video_bubble/video_player.dart';

//audio bubble
export 'src/views/audio_bubble/cometchat_audio_bubble.dart';
export 'src/views/audio_bubble/cometchat_audio_bubble_style.dart';

//file bubble
export 'src/views/file_bubble/cometchat_file_bubble.dart';
export 'src/views/file_bubble/cometchat_file_bubble_style.dart';

//deleted bubble
export 'src/views/deleted_bubble/cometchat_deleted_bubble.dart';
export 'src/views/deleted_bubble/cometchat_deleted_bubble_style.dart';

//message input
export 'src/views/message_input/cometchat_message_input.dart';
export 'src/views/message_input/cometchat_message_input_style.dart';

//receipt
export 'src/views/receipt/cometchat_receipt.dart';
export 'src/views/receipt/cometchat_receipt_style.dart';

//action sheet
export 'src/views/action_sheet/cometchat_action_sheet.dart';
export 'src/views/action_sheet/cometchat_attachment_option_sheet_style.dart';
export 'src/views/action_sheet/cometchat_message_option_sheet_style.dart';
export 'src/views/confirm_dialog/cometchat_confirm_dialog.dart';
export 'src/views/confirm_dialog/cometchat_confirm_dialog_style.dart';

//action sheet
export 'src/views/ai_option_sheet/cometchat_ai_option_sheet.dart';
export 'src/views/ai_option_sheet/cometchat_ai_option_sheet_style.dart';

//ai smart replies
export 'src/views/ai_smart_replies/cometchat_ai_smart_replies_style.dart';
export 'src/views/ai_smart_replies/cometchat_ai_smart_replies_view.dart';

//ai conversation starter
export 'src/views/ai_conversation_starter/cometchat_ai_conversation_starter_style.dart';
export 'src/views/ai_conversation_starter/cometchat_ai_conversation_starter_view.dart';

//quickView
export 'src/views/quick_view/quick_view_style.dart';
export 'src/views/quick_view/cometchat_quick_view.dart';

//single select
export 'src/views/single_select/single_select_style.dart';
export 'src/views/single_select/cometchat_single_select.dart';

//Web view
export 'src/views/web_view/cometchat_web_view.dart';
export 'src/views/web_view/web_view_style.dart';

//Decorated Container
export 'src/views/decorated_container/cometchat_decorated_container.dart';
export 'src/views/decorated_container/decorated_container_style.dart';

//Framework
export 'src/framework/data_source_decorator.dart';
export 'src/framework/data_source.dart';
export 'src/framework/extensions_data_source.dart';
export 'src/framework/chat_configurator.dart';

//card
export 'src/views/card/card_style.dart';
export 'src/views/card/cometchat_card.dart';

//card Bubble
export 'src/views/card_bubble/card_bubble_style.dart';
export 'src/views/card_bubble/cometchat_card_bubble.dart';

export 'src/views/action_bubble/cometchat_action_bubble.dart';
export 'src/views/action_bubble/cometchat_action_bubble_style.dart';

export 'src/cometchat_list/cometchat_list_controller.dart';
export 'src/cometchat_list/cometchat_search_list_controller.dart';
export 'src/cometchat_list/list_protocols.dart';
export 'src/cometchat_list/builder_protocol.dart';
export 'src/cometchat_list/cometchat_selectable.dart';

export 'src/view_models/cometchat_search_list_controller_protocol.dart';
export 'src/view_models/cometchat_message_list_controller_protocol.dart';
export 'src/view_models/cometchat_group_members_controller_protocol.dart';
export 'src/view_models/cometchat_conversations_controller_protocol.dart';
export 'src/view_models/cometchat_details_controller_protocol.dart';

//misc
export 'src/misc/bubble_utils.dart';
export 'src/misc/container_dotted_border.dart';
export 'src/misc/ui_event_handler.dart';

export 'src/misc/custom_state_view.dart';
export 'src/misc/status_indicator_utils.dart';
export 'src/misc/debouncer.dart';
export 'src/misc/media_picker.dart';
export 'src/misc/section_separator.dart';
export 'src/misc/utils.dart';
export 'src/misc/loading_indicator.dart';
export 'src/misc/audio_bubble_events.dart';
export 'src/misc/get_menu_view.dart';
export 'src/misc/custom_pop_up_menu.dart';

export 'src/models/snack_bar_configuration.dart';
export 'src/utils/snack_bar_utils.dart';
export 'src/utils/network_utils.dart';
export 'src/utils/interaction_message_utils.dart';

export 'src/views/media_recorder/cometchat_media_recorder.dart';
export 'src/views/media_recorder/cometchat_media_recorder_style.dart';

export 'src/framework/ai_extension.dart';
export 'src/events/utils/chat_sdk_event_initializer.dart';

export 'src/models/interactive_message/form_message.dart';
export 'src/models/interactive_message/card_message.dart';
export 'src/models/interactive_message/custom_interactive_message.dart';

//UI Elements
export 'src/models/interactive_elements/button_element.dart';
export 'src/models/interactive_elements/checkbox_element.dart';
export 'src/models/interactive_elements/dropdown_element.dart';
export 'src/models/interactive_elements/element_entity.dart';
export 'src/models/interactive_elements/label_element.dart';
export 'src/models/interactive_elements/radio_button_element.dart';
export 'src/models/interactive_elements/text_input_element.dart';
export 'src/models/interactive_elements/base_input_element.dart';
export 'src/models/interactive_elements/base_interactive_element.dart';
export 'src/models/interactive_elements/single_select_element.dart';
export 'src/models/interactive_elements/text_input_placeholder.dart';
export 'src/models/interactive_elements/date_time_element.dart';

export 'src/models/interactive_actions/url_navigation_action.dart';
export 'src/models/interactive_actions/api_action.dart';
export 'src/models/interactive_actions/action_entity.dart';
export 'src/models/interactive_elements/option_element.dart';

export 'src/models/interactive_element_styles/button_element_style.dart';
export 'src/models/interactive_element_styles/checkbox_element_style.dart';
export 'src/models/interactive_element_styles/dropdown_element_style.dart';
export 'src/models/interactive_element_styles/radio_button_element_style.dart';
export 'src/models/interactive_element_styles/text_input_element_style.dart';
export 'src/models/ai_option_style.dart';

export 'src/models/interactive_element_styles/date_time_element_style.dart';

export 'src/models/interactive_message/scheduler_message.dart';
export 'src/views/time_slot_selector/cometchat_time_slot_selector.dart';
export 'src/views/time_slot_selector/time_slot_selector_style.dart';
export 'src/utils/scheduler_utils.dart';

export 'src/views/typing_indicator/cometchat_typing_indicator_style.dart';

//reactions
export 'src/views/reactions/cometchat_reactions.dart';
export 'src/views/reactions/cometchat_reactions_style.dart';
export 'src/views/reaction_list/cometchat_reaction_list.dart';
export 'src/views/reaction_list/cometchat_reaction_list_style.dart';
export 'src/views/reaction_list/reaction_list_configuration.dart';
export 'src/views/reaction_list/cometchat_reaction_list_controller.dart';

export 'src/formatter/formatter.dart';
export 'src/formatter/cometchat_text_formatter.dart';
export 'src/formatter/mentions/cometchat_mentions_formatter.dart';

export 'src/models/suggestion_list_item.dart';
export 'src/events/message_events/message_composer_suggestions.dart';
export 'src/formatter/attributed_text.dart';

export 'src/formatter/cometchat_email_formatter.dart';
export 'src/formatter/cometchat_url_formatter.dart';
export 'src/formatter/cometchat_phone_number_formatter.dart';
export 'src/models/additional_configurations.dart';
export 'src/formatter/mentions/cometchat_mentions_style.dart';
export 'src/formatter/formatter_utils.dart';
export 'src/views/message_input/custom_text_editing_controller.dart';

export 'src/theme/colors/cometchat_color_helper.dart';
export 'src/theme/colors/cometchat_color_palette.dart';
export 'src/theme/spacing/cometchat_spacing.dart';
export 'src/theme/typography/cometchat_text_style_body.dart';
export 'src/theme/typography/cometchat_text_style_caption1.dart';
export 'src/theme/typography/cometchat_text_style_caption2.dart';
export 'src/theme/typography/cometchat_text_style_heading1.dart';
export 'src/theme/typography/cometchat_text_style_heading2.dart';
export 'src/theme/typography/cometchat_text_style_heading3.dart';
export 'src/theme/typography/cometchat_text_style_heading4.dart';
export 'src/theme/typography/cometchat_text_style_title.dart';
export 'src/theme/theme/cometchat_theme_helper.dart';
export 'src/theme/typography/cometchat_text_style_button.dart';
export 'src/theme/typography/cometchat_text_style_link.dart';
export 'src/theme/theme/cometchat_theme_mode.dart';
export 'src/theme/typography/cometchat_typography.dart';

export 'src/misc/cometchat_shimmer_effect.dart';

export 'src/models/extension_bubble_styles/cometchat_polls_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_collaborative_bubble_style.dart';
export 'src/utils/ui_state_utils.dart';
export 'src/models/extension_bubble_styles/cometchat_sticker_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_link_preview_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_message_translation_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_call_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_call_buttons_style.dart';
export 'src/models/extension_bubble_styles/cometchat_incoming_message_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_outgoing_message_bubble_style.dart';
export 'src/models/extension_bubble_styles/cometchat_moderation_style.dart';
export 'src/models/date_time_formatter_callback.dart';

//Ai Assistant bubble
export 'src/views/ai_assistant_bubble/cometchat_ai_assistant_bubble.dart';
export 'src/views/ai_assistant_bubble/cometchat_ai_assistant_bubble_Style.dart';
export 'src/views/stream_bubble/cometchat_stream_bubble.dart';

// Service
export 'src/services/cometchat_stream_service.dart';
export 'src/services/cometchat_stream_callback.dart';

// Stream Message model
export 'src/models/ai/stream_message.dart';

