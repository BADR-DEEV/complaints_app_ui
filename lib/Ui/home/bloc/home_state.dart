part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class NavigationState extends HomeState {
  final int selectedIndex;
  NavigationState(this.selectedIndex);
}

final class AddComplaintLoading extends HomeState {}

final class AddComplaintSucess extends HomeState {
  final AddComplaintResponse addComplaintResponse;

  AddComplaintSucess({required this.addComplaintResponse});
}

final class AddComplaintFailur extends HomeState {
  final String error;
  final AddComplaintResponse? addComplaintResponse;

  AddComplaintFailur(this.addComplaintResponse, {required this.error});
}
