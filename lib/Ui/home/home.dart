import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/home/bloc/home_bloc.dart';
import 'package:complaintsapp/Ui/home/widget/custom_appbar.dart';
import 'package:complaintsapp/Ui/home/widget/my_complaints_tab.dart';
import 'package:complaintsapp/Ui/home/widget/submit_complaint.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(),
            backgroundColor: AppColors.lightBackground,
            body: IndexedStack(
              index: state is NavigationState ? state.selectedIndex : 1,
              children: [
                MyComplaintsView(),
                SubmitComplaintView(),
              ],
            ),
            bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return BottomNavigationBar(
                  currentIndex: state is NavigationState ? state.selectedIndex : 1,
                  selectedItemColor: AppColors.primaryColor,
                  unselectedItemColor: Colors.grey,
                  onTap: (index) {
                    if (index == 0) {
                      context.read<HomeBloc>().add(NavigateMyComplaints());
                    } else {
                      context.read<HomeBloc>().add(NavigateSubmitComplaint());
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.list),
                      label: AppLocalizations.of(context)!.myComplaints,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add_circle_outline),
                      label: AppLocalizations.of(context)!.subComp,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
