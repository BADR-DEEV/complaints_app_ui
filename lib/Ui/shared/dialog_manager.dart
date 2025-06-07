import 'dart:async';
import 'package:complaintsapp/Ui/shared/constants/colors&fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DialogType { error, success, waiting, info }

class DialogManager {
  static bool _isDialogShowing = false;
  static Completer<void>? _dialogCompleter;
  static bool _isClosing = false;

  static Future<void> customDialog(
    BuildContext context,
    String title, {
    Color? color,
    DialogType? dialogType,
    String? buttonTitle,
    String? content,
    Function? onPressed,
    bool isDismissible = false,
    Widget? childWidget,
  }) async {
    // Ensure context is valid and close any existing dialog first
    if (_isDialogShowing && !_isClosing) {
      await closeDialog(context);
    }

    _isDialogShowing = true;

    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _buildDialog(
          context,
          title,
          color: color,
          dialogType: dialogType,
          buttonTitle: buttonTitle,
          content: content,
          onPressed: onPressed,
          isDismissible: isDismissible,
          childWidget: childWidget,
        );
      },
    ).then((_) {
      _isDialogShowing = false;
      _dialogCompleter?.complete();
      _dialogCompleter = null;
      _isClosing = false;
    });
  }

  static Future<void> closeDialog(BuildContext context) async {
    if (_isDialogShowing && !_isClosing) {
      try {
        _isClosing = true;
        _dialogCompleter = Completer<void>();
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
          await _dialogCompleter!.future;
        }
      } catch (e) {
        print("Error closing dialog: $e");
      } finally {
        _isDialogShowing = false;
        _isClosing = false;
        _dialogCompleter?.complete();
        _dialogCompleter = null;
      }
    }
  }

  static Widget _buildDialog(
    BuildContext context,
    String title, {
    Color? color,
    DialogType? dialogType,
    String? buttonTitle,
    String? content,
    Function? onPressed,
    bool isDismissible = false,
    Widget? childWidget,
  }) {
    return Dialog(
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            clipBehavior: Clip.none, // Allows the icon to be slightly outside the dialog
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32.0), // Add padding to adjust for icon
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildTitle(title, dialogType, childWidget),
                          if (content != null) _buildContent(content, dialogType, context) else const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildActions(
                              context,
                              buttonTitle,
                              onPressed,
                              isDismissible,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30, // Adjust to position icon above the dialog box
                left: 0,
                right: 0,
                child: Center(
                  child: _getDialogIcon(dialogType, 80), // Set larger icon size here
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildContent(String content, DialogType? dialogType, context) {
    return Localizations.override(
      context: context,
      //i did this because the error message comes from the server in english
      locale: dialogType == DialogType.error ? const Locale('en') : const Locale('ar'),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            content,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 10,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildActions(
    BuildContext context,
    String? buttonTitle,
    Function? onPressed,
    bool isDismissible,
  ) {
    if (buttonTitle == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isDismissible)
          TextButton(
            onPressed: () => Navigator.of(context).pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(fontFamily: 'Tajawal', color: Colors.black, fontSize: 16),
            ),
          ),
        TextButton(
          onPressed: () {
            closeDialog(context);
            if (onPressed != null) {
              onPressed();
            }
          },
          child: Text(
            buttonTitle,
            style: const TextStyle(fontFamily: 'Tajawal', color: Colors.red, fontSize: 16),
          ),
        ),
      ],
    );
  }

// Update _buildTitle to remove the icon from this method, as it’s now in the Stack
  static Widget _buildTitle(String title, DialogType? dialogType, Widget? childWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const SizedBox(height: 16), // Extra space to adjust the content position
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: null,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16), // Extra space to adjust the content position

          childWidget ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

// Update _getDialogIcon to accept a size parameter
  static Widget _getDialogIcon(DialogType? type, [double size = 60]) {
    switch (type) {
      case DialogType.error:
        return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: size,
            ));
      case DialogType.success:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700), // Increase duration for more visibility
            builder: (context, value, child) {
              // Define the scaling with a bounce-like effect
              final scale = Curves.elasticOut.transform(value);
              // Define the rotation effect
              final rotation = value * 0.5; // 180 degrees (0.5 rotations)
              // Define the opacity
              final opacity = value;

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: -rotation * 3.14159, // Negative to rotate clockwise
                    child: Transform.rotate(
                      angle: rotation * 3.14159,
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80, // Larger size for visibility
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      case DialogType.waiting:
        return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(strokeWidth: 5, color: AppColors.primaryColor)); // Increase stroke width for visibility
      case DialogType.info:
        return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(Icons.info, color: Colors.blue, size: size));
      default:
        return const SizedBox();
    }
  }
}

Widget _buildContent(String content, DialogType? dialogType, BuildContext context) {
  return _CollapsibleContent(
    content: content,
    dialogType: dialogType,
    context: context,
  );
}

class _CollapsibleContent extends StatefulWidget {
  final String content;
  final DialogType? dialogType;
  final BuildContext context;

  const _CollapsibleContent({
    required this.content,
    required this.dialogType,
    required this.context,
    Key? key,
  }) : super(key: key);

  @override
  State<_CollapsibleContent> createState() => _CollapsibleContentState();
}

class _CollapsibleContentState extends State<_CollapsibleContent> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isVisible = !_isVisible),
          child: Text(
            _isVisible ? 'Tap to hide message ▲' : 'Tap to show message ▼',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_isVisible)
          Localizations.override(
            context: widget.context,
            locale: widget.dialogType == DialogType.error ? const Locale('en') : const Locale('ar'),
            child: Text(
              widget.content,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16),
            ),
          ),
      ],
    );
  }
}
