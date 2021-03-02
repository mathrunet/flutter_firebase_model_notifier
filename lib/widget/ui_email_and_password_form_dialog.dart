part of firebase_model_notifier;

/// Display the login form.
///
/// Normally, [UILoginForm.show()] is executed to output with [UILoginForm.show()].
class UIEmailAndPasswordFormDialog extends StatefulWidget {
  /// Display the login form.
  ///
  /// Normally, [UILoginForm.show()] is executed to output with [UILoginForm.show()].
  ///
  /// [title]: Dialog title.
  /// [defaultSubmitText]: Default submit button text.
  /// [defaultSubmitAction]: Default submit button action.
  const UIEmailAndPasswordFormDialog({
    this.title = "Email & Password SignIn",
    this.defaultSubmitText = "Login",
    this.defaultSubmitAction,
  });

  /// Dialog title.
  final String title;

  /// Default submit button text.
  final String defaultSubmitText;

  /// Default submit button action.
  final void Function(String email, String password)? defaultSubmitAction;

  /// Display the login form.
  ///
  /// Normally, [UILoginForm.show()] is executed to output with [UILoginForm.show()].
  ///
  /// [title]: Dialog title.
  /// [defaultSubmitText]: Default submit button text.
  /// [defaultSubmitAction]: Default submit button action.
  static Future<void> show(
    BuildContext context, {
    String title = "Email & Password SignIn",
    String defaultSubmitText = "Login",
    void Function(String email, String password)? defaultSubmitAction,
  }) async {
    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return UIEmailAndPasswordFormDialog(
          title: title,
          defaultSubmitText: defaultSubmitText,
          defaultSubmitAction: defaultSubmitAction,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _UIEmailAndPasswordFormDialogState();
}

class _UIEmailAndPasswordFormDialogState
    extends State<UIEmailAndPasswordFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? email;
  String? password;

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
            widget.defaultSubmitAction?.call(email!, password!);
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
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Please enter a email address".localize(),
                  labelText: "Email".localize(),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter some text".localize();
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextFormField(
                obscureText: true,
                maxLength: 50,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Please enter a password".localize(),
                  labelText: "Password".localize(),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter some text".localize();
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
