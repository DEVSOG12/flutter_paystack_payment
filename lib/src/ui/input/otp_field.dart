import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpField extends TextFormField {
  OtpField({FormFieldSetter<String>? onSaved, required Color borderColor})
      : super(
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 25.0,
          ),
          autofocus: true,
          maxLines: 1,
          onSaved: onSaved,
          validator: (String? value) => value!.isEmpty ? 'Enter OTP' : null,
          obscureText: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            hintText: 'ENTER',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
            contentPadding: const EdgeInsets.all(10.0),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.0)),
          ),
        );
}
