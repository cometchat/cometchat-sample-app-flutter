import 'package:equatable/equatable.dart';

/// Domain entity representing a chat group
/// Pure Dart model with no dependencies on CometChat SDK
class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final String owner;
  final int memberCount;
  final List<String> members;
  final Map<String, dynamic>? metadata;
  final String type;

  const GroupEntity({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.owner,
    this.memberCount = 0,
    this.members = const [],
    this.metadata,
    this.type = 'public',
  });

  /// Create a copy of this group with some fields changed
  GroupEntity copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    String? owner,
    int? memberCount,
    List<String>? members,
    Map<String, dynamic>? metadata,
    String? type,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      memberCount: memberCount ?? this.memberCount,
      members: members ?? this.members,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
    );
  }

  /// Check if group has an icon
  bool get hasIcon => icon != null && icon!.isNotEmpty;

  /// Check if group is public
  bool get isPublic => type == 'public';

  /// Check if group is private
  bool get isPrivate => type == 'private';

  /// Check if member is in group
  bool isMember(String userId) => members.contains(userId);

  /// Add member to group
  GroupEntity addMember(String userId) {
    if (members.contains(userId)) return this;
    final newMembers = [...members, userId];
    return copyWith(members: newMembers, memberCount: memberCount + 1);
  }

  /// Remove member from group
  GroupEntity removeMember(String userId) {
    if (!members.contains(userId)) return this;
    final newMembers = members.where((id) => id != userId).toList();
    return copyWith(
      members: newMembers,
      memberCount: (memberCount - 1).clamp(0, memberCount),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    description,
    owner,
    memberCount,
    members,
    metadata,
    type,
  ];
}
