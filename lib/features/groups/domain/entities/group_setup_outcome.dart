class GroupSetupOutcome {
  final int groupId;
  final bool completed;
  final bool openGroupDetails;

  const GroupSetupOutcome({
    required this.groupId,
    required this.completed,
    this.openGroupDetails = false,
  });
}
