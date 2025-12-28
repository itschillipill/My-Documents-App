import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';

enum ErrorKeys{
  enterTitle,
  documentTitleExists,
  folderTitleExists,
  reachedMaxSize,
  selectFile,
  errorSavingFile,
  filesNotFound,
  failedToShare,
  notImplemented,
  ;
  String getMessage(BuildContext ctx){

    return switch (this) {
      ErrorKeys.enterTitle => ctx.l10n.enterTitle,
      ErrorKeys.documentTitleExists => ctx.l10n.documentTitleExists,
      ErrorKeys.folderTitleExists => ctx.l10n.folderTitleExists,
      ErrorKeys.reachedMaxSize => ctx.l10n.reachedMaxSize,
      ErrorKeys.selectFile => ctx.l10n.selectFile,
      ErrorKeys.errorSavingFile => ctx.l10n.errorSavingFile,
      ErrorKeys.filesNotFound => ctx.l10n.filesNotFound,
      ErrorKeys.failedToShare => ctx.l10n.failedToShare,
      ErrorKeys.notImplemented => ctx.l10n.notImplemented,
    };
  }
}