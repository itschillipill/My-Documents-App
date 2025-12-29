import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/pages/add_new_document_version.dart';
import 'package:my_documents/src/features/documents/widgets/build_tile.dart';
import 'package:my_documents/src/features/documents/widgets/document_error_page.dart';
import 'package:my_documents/src/features/documents/widgets/document_previewer.dart';
import 'package:my_documents/src/features/documents/widgets/menu_actions.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/widgets/build_section.dart';
import 'package:my_documents/src/widgets/label.dart';
import 'package:open_filex/open_filex.dart';

import '../document_actions.dart';
import 'document_version_history.dart';

class DocumentViewPage extends StatelessWidget {
  static PageRoute route(int documentId, {int? versionId}) =>
      AppPageRoute.build(
        page: DocumentViewPage._(documentId: documentId, versionId: versionId),
        transition: PageTransitionType.slideFromBottom,
      );
  final int documentId;
  final int? versionId;
  const DocumentViewPage._({required this.documentId, this.versionId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DocumentsCubit>();
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      buildWhen: (previous, current) => current is DocumentsLoaded,
      builder: (context, state) {
        final document = cubit.getDocumentById(documentId);
        final documentVersion = document?.versions.firstWhere(
          (v) => v.id == (versionId ?? (document.currentVersionId)),
          orElse: () => document.versions.first,
        );
        if (document == null || documentVersion == null) {
          return DocumentErrorPage(
            getErrorInfo:
                () => debugPrint(
                  "state: $state, document: $document,documentVersion: $documentVersion",
                ),
          );
        }
        bool isCurrent = document.currentVersionId == documentVersion.id;
        debugPrint("Document: $document");
        debugPrint(
          "Current Document Version: ${documentVersion.id}, serched for: ${versionId ?? document.currentVersionId}",
        );
        return Scaffold(
          appBar: _buildAppBar(document, isCurrent, context),
          body: SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (documentVersion.comment?.isNotEmpty == true)
                    BuildSection(
                      title: context.l10n.comment,
                      icon: Icons.comment_rounded,
                      children: [
                        BorderBox(
                          child: SelectableText(documentVersion.comment!),
                        ),
                      ],
                    ),

                  _buidDocumentInfo(context, documentVersion, isCurrent),
                  _buildDocumentPreview(context, documentVersion),

                  _buildDocumentActions(
                    context,
                    document,
                    documentVersion,
                    isCurrent,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

PreferredSizeWidget _buildAppBar(
  Document document,
  bool isCurrent,
  BuildContext ctx,
) {
  return AppBar(
    title: Text(document.title),
    centerTitle: false,
    actions:
        isCurrent
            ? [
              MenuActions(
                actions: [
                  (
                    ChangeDetails$DocumentAction(
                      context: ctx,
                      document: document,
                    ).call,
                    ctx.l10n.changeDetails,
                  ),
                ],
              ),
            ]
            : null,
  );
}

Widget _buidDocumentInfo(
  BuildContext ctx,
  DocumentVersion documentVersion,
  bool isCurrent,
) {
  final Color iconColor = Theme.of(
    ctx,
  ).colorScheme.primary.withValues(alpha: 0.7);
  final TextStyle textStyle = Theme.of(
    ctx,
  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500);
  final DocumentStatus status =
      isCurrent ? documentVersion.status : DocumentStatus.archivated;
  return BorderBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.calendar_today, color: iconColor),
            Expanded(child: Text(ctx.l10n.uploadDate, style: textStyle)),
            Text(documentVersion.uploadedAt.formatted(ctx), style: textStyle),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Icon(Icons.timer, color: iconColor),
            Expanded(child: Text(ctx.l10n.expiresAt, style: textStyle)),
            Text(
              documentVersion.expirationDate?.formatted(ctx) ??
                  ctx.l10n.noExpiration,
              style: textStyle,
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Icon(Icons.circle, color: status.color),
            Expanded(child: Text(ctx.l10n.status, style: textStyle)),
            Label(label: status.localizedText(ctx), color: status.color),
          ],
        ),
      ],
    ),
  );
}

Widget _buildDocumentPreview(
  BuildContext ctx,
  DocumentVersion documentVersion,
) {
  return BorderBox(
    child: Column(
      spacing: 8,
      children: [
        DocumentPreviewer(
          path: documentVersion.filePath,
          isImage: documentVersion.isImage,
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed:
                () async => await OpenFilex.open(documentVersion.filePath),
            label: Text(ctx.l10n.openExternal),
            icon: Icon(Icons.remove_red_eye_rounded),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDocumentActions(
  BuildContext ctx,
  Document document,
  DocumentVersion documentVersion,
  bool isCurrent,
) {
  return BorderBox(
    child: Column(
      children: [
        BuildTile(
          title: ctx.l10n.shareDocument,
          icon: Icons.share_rounded,
          onTap: Share$DocumentAction(documents: [document], context: ctx).call,
        ),
        if (isCurrent) ...[
          BuildTile(
            title: ctx.l10n.uploadNewVersion,
            icon: Icons.file_download_outlined,
            onTap:
                () async => await Navigator.push(
                  ctx,
                  AddNewDocumentVersion.route(document.id),
                ),
          ),
          BuildTile(
            title: ctx.l10n.manageVersions,
            icon: Icons.history_rounded,
            onTap:
                () => Navigator.push(
                  ctx,
                  DocumentVersionHistory.route(document.id),
                ),
          ),
          BuildTile(
            title: ctx.l10n.deleteDocument,
            icon: Icons.delete_rounded,
            isDanger: true,
            onTap:
                Delete$DocumentAction(
                  documentsIds: [document.id],
                  context: ctx,
                ).call,
          ),
        ],
      ],
    ),
  );
}
