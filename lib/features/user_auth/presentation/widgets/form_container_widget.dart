import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final bool enabled;

  const FormContainerWidget({
    super.key,
    this.controller,
    this.isPasswordField,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
    this.textInputAction,
    this.prefixIcon,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
  });

  @override
  State<FormContainerWidget> createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPasswordField == true;

    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      keyboardType: widget.inputType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      obscureText: isPassword && _obscureText,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      cursorColor: CarNationColors.accentSoft,
      style: TextStyle(
        color: widget.enabled
            ? CarNationColors.textPrimary
            : CarNationColors.textMuted,
        fontSize: 16,
      ),
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        errorMaxLines: 3,
        constraints: const BoxConstraints(minHeight: 56),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        filled: true,
        fillColor: widget.enabled
            ? CarNationColors.surfaceRaised
            : CarNationColors.surface,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(
                widget.prefixIcon,
                color: CarNationColors.textMuted,
              ),
        suffixIcon: isPassword
            ? IconButton(
                tooltip: _obscureText ? 'Show password' : 'Hide password',
                onPressed: widget.enabled ? _togglePasswordVisibility : null,
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _obscureText
                      ? CarNationColors.textMuted
                      : CarNationColors.accentSoft,
                ),
              )
            : null,
        border: _border(CarNationColors.border),
        enabledBorder: _border(CarNationColors.border),
        disabledBorder: _border(CarNationColors.border),
        focusedBorder: _border(CarNationColors.accent, width: 1.5),
        errorBorder: _border(CarNationColors.danger),
        focusedErrorBorder: _border(CarNationColors.danger, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(CarNationRadii.control),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
