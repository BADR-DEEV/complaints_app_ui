import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:complaintsapp/Ui/shared/dialog_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollapsibleErrorWidget extends StatefulWidget {
  final String errorText;
  final DialogType? dialogType;

  const CollapsibleErrorWidget({
    Key? key,
    required this.errorText,
    this.dialogType,
  }) : super(key: key);

  @override
  _CollapsibleErrorWidgetState createState() => _CollapsibleErrorWidgetState();
}

class _CollapsibleErrorWidgetState extends State<CollapsibleErrorWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? '${AppLocalizations.of(context)!.unTapToClose} ▲' : '${AppLocalizations.of(context)!.tapFormoreDetails} ▼',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_isExpanded)
          Localizations.override(
            context: context,
            locale: widget.dialogType == DialogType.error ? const Locale('en') : const Locale('ar'),
            child: Text(
              widget.errorText,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16),
            ),
          ),
      ],
    );
  }
}
