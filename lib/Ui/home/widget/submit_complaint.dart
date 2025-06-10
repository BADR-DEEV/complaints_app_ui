import 'dart:io';

import 'package:complaintsapp/AppClient/Models/complaint/add_complaint_req.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/Ui/home/bloc/home_bloc.dart';
import 'package:complaintsapp/Ui/home/widget/dotted_border_box.dart';
import 'package:complaintsapp/Ui/shared/collapse_menu.dart';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:complaintsapp/Ui/shared/dialog_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitComplaintView extends StatefulWidget {
  const SubmitComplaintView({super.key});

  @override
  State<SubmitComplaintView> createState() => _SubmitComplaintViewState();
}

class _SubmitComplaintViewState extends State<SubmitComplaintView> {
  final List<String> _categories = ['Water', 'Electricity', 'Roads', 'Sanitation', 'Other'];
  String? _selectedCategory;
  int? category;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is AddComplaintSucess) {
            DialogManager.customDialog(
              isDismissible: false,
              context,
              AppLocalizations.of(context)!.yourComplaintSubmited,
              dialogType: DialogType.success,
              buttonTitle: AppLocalizations.of(context)!.ok,
              onPressed: () {},
            );
          } else if (state is AddComplaintLoading) {
            DialogManager.customDialog(
              context,
              AppLocalizations.of(context)!.pleaseWait,
              dialogType: DialogType.waiting,
              isDismissible: false,
            );
          } else if (state is AddComplaintFailur) {
            DialogManager.customDialog(
              context,
              AppLocalizations.of(context)!.loginError,
              dialogType: DialogType.error,
              buttonTitle: AppLocalizations.of(context)!.ok,
              onPressed: () {},
              childWidget: CollapsibleErrorWidget(
                errorText: state.addComplaintResponse?.message ?? state.error.toString(),
                dialogType: DialogType.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.submitAcomplaint,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 15),
                TextFormField(
                  textDirection: SharedPrefs().language == "en" ? TextDirection.ltr : TextDirection.rtl,
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.titleComplaint,
                    labelStyle: GoogleFonts.cairo(fontSize: 16),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descController,
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    labelStyle: GoogleFonts.cairo(fontSize: 16),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.category,
                    labelStyle: GoogleFonts.cairo(fontSize: 16),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      value != null ? category = _categories.indexOf(value) + 1 : null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Handle file picking here
                  },
                  child: DottedBorderBox(
                    onImageSelected: (image) {
                      // This function gets called from DottedBorderBox.
                      // We update the parent's state with the selected image.
                      setState(() {
                        _selectedImage = image;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      context.read<HomeBloc>().add(SubmitComplaintEvent(
                            addComplaintRequest:
                                AddComplaintRequest(categoriesId: category ?? 1, complainTitle: _titleController.text, complainDescription: _descController.text, image: _selectedImage),
                          ));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.submit,
                      style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
