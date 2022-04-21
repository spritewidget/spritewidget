import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeViewDialog extends StatelessWidget {
  const CodeViewDialog({
    Key? key,
    required this.code,
  }) : super(key: key);

  final String code;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SelectableText(code),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
          },
          child: const Text('COPY'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('DONE'),
        ),
      ],
    );
  }
}

void showCodeViewDialog(BuildContext context, String code) {
  showDialog(
    context: context,
    builder: (context) {
      return CodeViewDialog(code: code);
    },
  );
}
