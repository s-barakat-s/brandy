import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.centerTitle = false,
  });

  static double floatingActionButtonScrollPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 104;
  }

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final canPop = GoRouter.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: leading ??
            (canPop
                ? IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  )
                : null),
        actions: actions,
        centerTitle: centerTitle,
        scrolledUnderElevation: 0,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
