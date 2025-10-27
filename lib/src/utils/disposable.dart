import 'dart:async';

import 'package:flutter/material.dart';

mixin Disposable<T extends StatefulWidget> on State<T>{
 final List<Function> _disposeStack = [];
 void disposable(Function obj){
  _disposeStack.add(obj);
 }

Future <void> _runDisposeStack()async{
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