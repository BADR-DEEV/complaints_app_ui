part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class NavigateMyComplaints extends HomeEvent {}

final class NavigateSubmitComplaint extends HomeEvent {}

final class SubmitComplaintEvent extends HomeEvent {
  final AddComplaintRequest addComplaintRequest;

  SubmitComplaintEvent({required this.addComplaintRequest});
}
