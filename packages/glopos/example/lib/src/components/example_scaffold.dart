import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_bar.dart';

class ExampleScaffold extends StatelessWidget {
  const ExampleScaffold({
    Key? key,
    required this.id,
    required this.title,
    this.parameters,
    this.backgroundColor,
    required this.body,
  }) : super(key: key);

  final String id;

  final String title;

  final List<Widget>? parameters;

  final Color? backgroundColor;

  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MainBar(
          title: title,
          actions: [
            IconButton(
              onPressed: _openSourceCode,
              icon: const Icon(Icons.code),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (parameters != null) ...[
              _ParametersBar(children: parameters!),
              const Divider(height: 0),
            ],
            Expanded(child: body),
          ],
        ),
      );

  void _openSourceCode() {
    const repoUrl = 'https://github.com/blaugold/glopos';
    const examplePagesUrl =
        '$repoUrl/blob/main/packages/glopos/example/lib/src/pages';
    final url = '$examplePagesUrl/$id.dart';
    launch(url);
  }
}

class _ParametersBar extends StatelessWidget {
  const _ParametersBar({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 20),
              for (final child in children) ...[
                child,
                const SizedBox(width: 20),
              ]
            ],
          ),
        ),
      );
}
