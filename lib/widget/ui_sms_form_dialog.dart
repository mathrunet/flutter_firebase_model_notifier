part of firebase_model_notifier;

/// Display the login form.
///
/// Normally, [UILoginForm.show()] is executed to output with [UILoginForm.show()].
class UISMSFormDialog extends StatefulWidget {
  /// Display the login form.
  ///
  /// Normally, [UILoginForm.show()] is executed to output with [UILoginForm.show()].
  ///
  /// [title]: Dialog title.
  /// [defaultSubmitText]: Default submit button text.
  /// [defaultSubmitAction]: Default submit button action.
  const UISMSFormDialog({
    this.title = "SMS SignIn",
    this.defaultSubmitText = "Login",
    this.defaultSubmitAction,
  });

  /// Dialog title.
  final String title;

  /// Default submit button text.
  final String defaultSubmitText;

  /// Default submit button action.
  final void Function(String phoneNumber)? defaultSubmitAction;

  /// Display the login form.
  ///
  /// Normally, [UILoginForm.show()] is executed to output with [UILoginForm.show()].
  ///
  /// [title]: Dialog title.
  /// [defaultSubmitText]: Default submit button text.
  /// [defaultSubmitAction]: Default submit button action.
  static Future<void> show(
    BuildContext context, {
    String title = "SMS SignIn",
    String defaultSubmitText = "Login",
    void Function(String phoneNumber)? defaultSubmitAction,
  }) async {
    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return UISMSFormDialog(
          title: title,
          defaultSubmitText: defaultSubmitText,
          defaultSubmitAction: defaultSubmitAction,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _UISMSFormDialogState();
}

class _UISMSFormDialogState extends State<UISMSFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? phoneNumber;

  /// Build method.
  ///
  /// [BuildContext]: Build Context.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title.localize()),
      actions: <Widget>[
        TextButton(
          child: Text(widget.defaultSubmitText.localize()),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            if (!formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context, rootNavigator: true).pop();
            if (widget.defaultSubmitAction == null) {
              return;
            }
            formKey.currentState?.save();
            widget.defaultSubmitAction?.call(phoneNumber!);
          },
        )
      ],
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextFormField(
                maxLength: 200,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Please enter a phone number".localize(),
                  labelText: "Phone Number".localize(),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter some text".localize();
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
