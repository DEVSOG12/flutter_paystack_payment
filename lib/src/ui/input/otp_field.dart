import 'package:flutter/material.dart';

class OtpField extends TextFormField {
  OtpField(
      {Key? key, FormFieldSetter<String>? onSaved, required Color borderColor})
      : super(
          key: key,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
            border: const OutlineInputBorder(),
            isDense: true,
            hintText: 'ENTER',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
            contentPadding: const EdgeInsets.all(10.0),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.0)),
          ),
        );
}
