import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

enum CometChatPollsBubbleType { result, poll }

///[CometChatPollsBubble] is a widget that is rendered as the content view for `PollsExtension`
///
/// ```dart
/// CometChatPollsBubble(
///  pollQuestion: "What is your favorite color?",
///  options: [
///    PollOptions(id: "1", optionText: "Red"),
///    PollOptions(id: "2", optionText: "Green"),
///    PollOptions(id: "3", optionText: "Blue")
///  ],
///  pollId: "123456",
///  choosePoll: (String vote, String id) async {
///    // Code to handle the poll vote
///  },
/// );
///
/// ```
class CometChatPollsBubble extends StatefulWidget {
  const CometChatPollsBubble({
    super.key,
    this.loggedInUser,
    this.pollQuestion,
    this.options,
    this.pollId,
    required this.choosePoll,
    this.senderUid,
    this.metadata,
    this.alignment,
    this.style,
  });

  ///[pollQuestion] if poll question is passed then that is used instead of poll question from message Object
  final String? pollQuestion;

  ///[options] if options is passed then that is used instead of options from message Object
  final List<PollOptions>? options;

  ///[pollId] if poll id is passed then that is used instead of poll id from message Object
  final String? pollId;

  ///[loggedInUser] logged in user id to check if logged user voted or not
  final String? loggedInUser;

  ///[choosePoll] vote for the poll
  final Future<void> Function(String vote, String id) choosePoll;

  ///[senderUid] uid of poll creator
  final String? senderUid;

  ///[metadata] metadata attached to the poll message
  final Map<String, dynamic>? metadata;

  ///[style] style for the poll bubble
  final CometChatPollsBubbleStyle? style;

  ///[alignment] of the bubble used to set default colors for background and text
  final BubbleAlignment? alignment;

  @override
  State<CometChatPollsBubble> createState() => _CometChatPollsBubbleState();
}

class _CometChatPollsBubbleState extends State<CometChatPollsBubble> {
  /// Tracks which option is currently being voted on (null = no vote in progress)
  String? _votingOptionId;

  List<Widget> _getAvatars(
    List<User> voters,
    BubbleAlignment? alignment,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatPollsBubbleStyle? style,
  ) {
    return voters
        .map(
          (User user) => Align(
            widthFactor: 0.5,
            child: CometChatAvatar(
              name: user.name,
              image: user.avatar,
              height: 20,
              width: 20,
              style: CometChatAvatarStyle(
                placeHolderTextStyle: TextStyle(
                  fontSize: typography.caption2?.regular?.fontSize,
                ),
                border: Border.all(
                  color:
                      (alignment == BubbleAlignment.right
                          ? colorPalette.primary
                          : colorPalette.neutral300) ??
                      Colors.transparent,
                  width: 1.5,
                ),
              ).merge(style?.voterAvatarStyle),
            ),
          ),
        )
        .toList();
  }

  Widget _buildRadio(
    int index,
    String id,
    String value,
    String chosenId,
    String pollId,
    int votes,
    int totalVotes,
    List<User> voters,
    CometChatPollsBubbleStyle style,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography, {
    bool isLast = false,
  }) {
    int count = votes;
    double percentage = totalVotes == 0 ? 0 : (count / totalVotes);
    final bool isVoting = _votingOptionId == id;

    return GestureDetector(
      onTap: _votingOptionId != null
          ? null
          : () async {
              setState(() => _votingOptionId = id);
              try {
                await widget.choosePoll(id, pollId);
              } finally {
                if (mounted) {
                  setState(() => _votingOptionId = null);
                }
              }
            },
      child: Container(
        margin: isLast ? null : EdgeInsets.only(bottom: spacing.margin5 ?? 0),
        decoration: BoxDecoration(
          color: style.pollOptionsBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 20,
              margin: EdgeInsets.only(
                right: spacing.margin2 ?? 0,
                top: spacing.margin1 ?? 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(spacing.radius3 ?? 0),
                border: isVoting
                    ? null
                    : Border.all(
                        width: 1.5,
                        color:
                            (widget.alignment == BubbleAlignment.right
                                ? colorPalette.white
                                : id == chosenId
                                ? colorPalette.primary
                                : colorPalette.iconSecondary) ??
                            Colors.transparent,
                      ),
                color: isVoting
                    ? Colors.transparent
                    : (id == chosenId
                              ? style.selectedOptionColor ??
                                    (widget.alignment == BubbleAlignment.right
                                        ? colorPalette.white
                                        : colorPalette.primary)
                              : style.unSelectedOptionColor) ??
                          style.radioButtonColor,
              ),
              child: isVoting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.alignment == BubbleAlignment.right
                            ? colorPalette.white
                            : colorPalette.primary,
                      ),
                    )
                  : id == chosenId
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color:
                          style.iconColor ??
                          (widget.alignment == BubbleAlignment.right
                              ? colorPalette.primary
                              : colorPalette.white),
                    )
                  : null,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.padding1 ?? 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            style: TextStyle(
                              color: widget.alignment == BubbleAlignment.right
                                  ? colorPalette.white
                                  : colorPalette.neutral900,
                              fontSize: typography.body?.regular?.fontSize,
                              fontWeight: typography.body?.regular?.fontWeight,
                            ).merge(style.pollOptionsTextStyle),
                          ),
                        ),
                        Wrap(
                          children: [
                            if (votes > 0)
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _getAvatars(
                                    voters,
                                    widget.alignment,
                                    colorPalette,
                                    typography,
                                    style,
                                  ),
                                ),
                              ),
                            if (votes > 0)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: spacing.padding2 ?? 0,
                                ),
                                child: Text(
                                  "$votes",
                                  style: TextStyle(
                                    color:
                                        widget.alignment ==
                                            BubbleAlignment.right
                                        ? colorPalette.white
                                        : colorPalette.neutral900,
                                    fontSize:
                                        typography.body?.regular?.fontSize,
                                    fontWeight:
                                        typography.body?.regular?.fontWeight,
                                  ).merge(style.voteCountTextStyle),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    color:
                        style.progressColor ??
                        (widget.alignment == BubbleAlignment.right
                            ? colorPalette.white
                            : colorPalette.primary),
                    backgroundColor:
                        style.progressBackgroundColor ??
                        (widget.alignment == BubbleAlignment.right
                            ? colorPalette.extendedPrimary700
                            : colorPalette.neutral400),
                    minHeight: 8,
                    value: percentage,
                    borderRadius: BorderRadius.circular(spacing.radius4 ?? 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollWidget(
    List<PollOptions> options,
    String chosenId,
    String pollId,
    int totalVotes,
    CometChatPollsBubbleStyle style,
    CometChatColorPalette colorPalette,
    CometChatSpacing spacing,
    CometChatTypography typography,
  ) {
    return Column(
      children: [
        for (int index = 0; index < options.length; index++)
          _buildRadio(
            index,
            options[index].id,
            options[index].optionText,
            chosenId,
            pollId,
            options[index].voteCount,
            totalVotes,
            options[index].voters,
            style,
            colorPalette,
            spacing,
            typography,
            isLast: index == options.length - 1,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String chosenId = "";
    int totalVotes = 0;

    List<PollOptions> options = [];
    CometChatPollsBubbleStyle style =
        CometChatThemeHelper.getTheme<CometChatPollsBubbleStyle>(
          context: context,
          defaultTheme: CometChatPollsBubbleStyle.of,
        ).merge(widget.style);
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    if (widget.options != null) {
      options = widget.options!;
      for (var opt in options) {
        totalVotes += opt.voteCount;
      }
    } else if (widget.metadata != null) {
      if (widget.metadata != null && widget.metadata!.isNotEmpty) {
        totalVotes = widget.metadata?["total"];
        Map<String, dynamic> opt = widget.metadata?["options"] ?? {};
        for (var item in opt.keys) {
          Map<String, dynamic> votersUid = opt[item]["voters"] ?? {};
          List<User> voters = votersUid.entries
              .map(
                (entry) => User(
                  uid: entry.key,
                  name: entry.value["name"],
                  avatar: entry.value["avatar"],
                ),
              )
              .toList();

          PollOptions optionModel = PollOptions(
            id: item.toString(),
            optionText: opt[item]["text"],
            voteCount: opt[item]["count"],
            votersUid: votersUid.keys.toList(),
            voters: voters,
          );
          options.add(optionModel);
        }
      }
    }

    for (PollOptions opt in options) {
      if (opt.votersUid.contains(widget.loggedInUser)) {
        chosenId = opt.id;
      }
    }

    return Container(
      width: 232,
      decoration: BoxDecoration(
        border: style.border,
        borderRadius:
            style.borderRadius ?? BorderRadius.circular(spacing.radius2 ?? 0),
        color: style.backgroundColor ?? Colors.transparent,
      ),
      padding: EdgeInsets.all(spacing.padding2 ?? 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing.padding4 ?? 0),
            child: Text(
              widget.pollQuestion ?? '',
              style: TextStyle(
                fontSize: typography.heading4?.bold?.fontSize,
                fontWeight: typography.heading4?.bold?.fontWeight,
                fontFamily: typography.heading4?.bold?.fontFamily,
                color: widget.alignment == BubbleAlignment.right
                    ? colorPalette.white
                    : colorPalette.neutral900,
              ).merge(style.questionTextStyle),
            ),
          ),
          _buildPollWidget(
            options,
            chosenId,
            widget.pollId ?? '',
            totalVotes,
            style,
            colorPalette,
            spacing,
            typography,
          ),
        ],
      ),
    );
  }
}

class PollOptions {
  ///creates model for poll options and result
  PollOptions({
    required this.optionText,
    required this.voteCount,
    required this.id,
    required this.votersUid,
    required this.voters,
  });

  ///[id] poll option id
  final String id;

  ///[optionText] option text
  final String optionText;

  ///[voteCount] vote count for this option
  int voteCount;

  ///[votersUid] list of voters uid
  final List<String> votersUid;

  final List<User> voters;
}
