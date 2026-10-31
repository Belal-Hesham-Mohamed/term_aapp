import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/study_group.dart';
import '../../domain/repositories/group_repository.dart';
import '../state/group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepository repository;
  Timer? _searchTimer;
  String _query = '';
  int _listRequestId = 0;
  bool _saving = false;
  bool lastSaveWasDuplicate = false;

  GroupCubit(this.repository) : super(GroupLoading());

  Future<void> loadGroups() async {
    final requestId = ++_listRequestId;
    await _loadList(requestId, _query);
  }

  Future<void> searchGroups(String query) async {
    _query = query.trim();
    _searchTimer?.cancel();
    final requestId = ++_listRequestId;
    final queryToSearch = _query;
    if (queryToSearch.isEmpty) {
      await _loadList(requestId, '');
      return;
    }
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _loadList(requestId, queryToSearch);
    });
  }

  Future<void> _loadList(int requestId, String query) async {
    try {
      final groups = query.isEmpty
          ? await repository.getGroups()
          : await repository.searchGroups(query);
      if (!isClosed && requestId == _listRequestId) {
        emit(GroupListLoaded(groups, query: query));
      }
    } catch (error) {
      if (!isClosed && requestId == _listRequestId) {
        emit(GroupFailure(error.toString()));
      }
    }
  }

  Future<bool> saveGroup({
    StudyGroup? existing,
    required String name,
    required String targetGrade,
    String? notes,
  }) async {
    if (_saving) return false;
    lastSaveWasDuplicate = false;
    final cleanName = name.trim();
    final cleanGrade = targetGrade.trim();
    if (cleanName.isEmpty || cleanGrade.isEmpty) return false;
    _saving = true;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (existing == null) {
        await repository.createGroup(
          StudyGroup(
            id: 0,
            name: cleanName,
            targetGrade: cleanGrade,
            notes: notes,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await repository.updateGroup(
          StudyGroup(
            id: existing.id,
            name: cleanName,
            targetGrade: cleanGrade,
            notes: notes,
            createdAt: existing.createdAt,
            updatedAt: now,
          ),
        );
      }
      await loadGroups();
      return true;
    } catch (error) {
      lastSaveWasDuplicate = error is DuplicateGroupNameException;
      if (!isClosed) emit(GroupFailure(error.toString()));
      return false;
    } finally {
      _saving = false;
    }
  }

  Future<void> loadDetails(int groupId) async {
    emit(GroupDetailsLoading());
    try {
      final group = await repository.getGroup(groupId);
      final students = await repository.getEnrolledStudents(groupId);
      if (!isClosed) emit(GroupDetailsLoaded(group, students));
    } catch (error) {
      if (!isClosed) emit(GroupFailure(error.toString()));
    }
  }

  Future<void> loadAvailableStudents(int groupId) async {
    try {
      final students = await repository.getAvailableStudents(groupId);
      if (!isClosed) emit(GroupAvailableStudentsLoaded(students));
    } catch (error) {
      if (!isClosed) emit(GroupFailure(error.toString()));
    }
  }

  Future<bool> addStudents(int groupId, List<int> studentIds) async {
    try {
      if (studentIds.isEmpty) return true;
      await repository.addStudents(groupId, studentIds);
      await loadDetails(groupId);
      return true;
    } catch (error) {
      if (!isClosed) emit(GroupFailure(error.toString()));
      return false;
    }
  }

  Future<bool> removeStudent(int groupId, int studentId) async {
    try {
      await repository.removeStudent(groupId, studentId);
      await loadDetails(groupId);
      return true;
    } catch (error) {
      if (!isClosed) emit(GroupFailure(error.toString()));
      return false;
    }
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
