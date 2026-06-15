import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/widgets/custom_text_field.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? inputStyle;
  final Widget? prefixIcon;

  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.inputFormatters,
    this.enabled = true,
    this.labelStyle,
    this.hintStyle,
    this.inputStyle,
    this.prefixIcon,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      textInputType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: GestureDetector(
        onTap: _toggleObscureText,
        child: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: ColorManager.iconColor,
        ),
      ),
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      labelStyle: widget.labelStyle,
      hintStyle: widget.hintStyle,
      inputStyle: widget.inputStyle,
    );
  }
}
