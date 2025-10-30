import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin Disposable<T extends StatefulWidget> on State<T> {
  final List<Function> _disposeStack = [];
  void disposable(Function obj) {
    _disposeStack.add(obj);
  }

  Future<void> _runDisposeStack() async {
    for (var i in _disposeStack) {
      try {
        await i.call();
        debugPrint("dispose stack $i finished");
      } catch (e) {
        debugPrint("error in dispose stack $i. $e");
      }
    }
    debugPrint("dispose stack finished");
    _disposeStack.clear();
  }

  @override
  @mustCallSuper
  void dispose() {
    unawaited(_runDisposeStack());
    super.dispose();
  }
}


class ValidatableBlockBuilder<B extends StateStreamable<S>, S, T> extends StatelessWidget {
  final BlocWidgetBuilder<S>? orElse;
  final BlocWidgetBuilder<T> builder;
  final B? bloc;

  const ValidatableBlockBuilder({
    super.key,
    this.bloc,
    required this.orElse,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      builder: (context, state) {
        if (state is T) {
          return builder(context, state);
        } else if (orElse != null){
          return orElse!(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
