import 'package:diffutil_dart/diffutil.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Diff delegate for comparing BaseMessage lists
///
/// Used by the animated list to efficiently calculate which messages
/// were added, removed, or changed when the list is replaced.
class MessageListDiff extends ListDiffDelegate<BaseMessage> {
  MessageListDiff(super.oldList, super.newList);

  @override
  bool areContentsTheSame(int oldItemPosition, int newItemPosition) {
    final oldMsg = oldList[oldItemPosition];
    final newMsg = newList[newItemPosition];

    return oldMsg.id == newMsg.id &&
        oldMsg.updatedAt == newMsg.updatedAt &&
        oldMsg.deletedAt == newMsg.deletedAt &&
        oldMsg.deliveredAt == newMsg.deliveredAt &&
        oldMsg.readAt == newMsg.readAt &&
        oldMsg.sentAt == newMsg.sentAt &&
        _areReactionsEqual(oldMsg, newMsg);
  }

  @override
  bool areItemsTheSame(int oldItemPosition, int newItemPosition) {
    final oldMsg = oldList[oldItemPosition];
    final newMsg = newList[newItemPosition];

    if (oldMsg.id > 0 && newMsg.id > 0) {
      return oldMsg.id == newMsg.id;
    }

    final oldMuid = oldMsg.muid;
    final newMuid = newMsg.muid;
    if (oldMuid.isNotEmpty && newMuid.isNotEmpty) {
      return oldMuid == newMuid;
    }

    return false;
  }

  bool _areReactionsEqual(BaseMessage oldMsg, BaseMessage newMsg) {
    final oldReactions = oldMsg.reactions;
    final newReactions = newMsg.reactions;

    if (oldReactions.length != newReactions.length) return false;

    for (int i = 0; i < oldReactions.length; i++) {
      if (oldReactions[i].reaction != newReactions[i].reaction ||
          oldReactions[i].count != newReactions[i].count) {
        return false;
      }
    }

    return true;
  }
}
