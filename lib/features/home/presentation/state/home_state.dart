import '../../domain/entities/home_summary.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeSummary summary;
  HomeLoaded(this.summary);
}

class HomeFailure extends HomeState {
  final String message;
  HomeFailure(this.message);
}
