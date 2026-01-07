// class MyDocumentsProvider : DocumentsProvider() {

//     private lateinit var db: DocumentsDb

//     override fun onCreate(): Boolean {
//         db = DocumentsDb(context!!)
//         return true
//     }

//     // источник в проводнике
//     override fun queryRoots(
//         projection: Array<out String>?
//     ): Cursor {

//         val cursor = MatrixCursor(
//             projection ?: DEFAULT_ROOT_PROJECTION
//         )

//         cursor.newRow().apply {
//             add(Root.COLUMN_ROOT_ID, "my_docs_root")
//             add(Root.COLUMN_TITLE, "Мои документы")
//             add(Root.COLUMN_DOCUMENT_ID, "root")
//             add(Root.COLUMN_MIME_TYPES, "*/*")
//             add(
//                 Root.COLUMN_FLAGS,
//                 Root.FLAG_SUPPORTS_SEARCH
//             )
//         }

//         return cursor
//     }

//     // список документов (ТОЛЬКО актуальные)
//     override fun queryChildDocuments(
//         parentDocumentId: String,
//         projection: Array<out String>?,
//         sortOrder: String?
//     ): Cursor {

//         val cursor = MatrixCursor(
//             projection ?: DEFAULT_DOCUMENT_PROJECTION
//         )

//         db.getActualDocuments().forEach { doc ->
//             cursor.newRow().apply {
//                 add(Document.COLUMN_DOCUMENT_ID, doc.id)
//                 add(Document.COLUMN_DISPLAY_NAME, doc.name)
//                 add(Document.COLUMN_MIME_TYPE, doc.mime)
//                 add(Document.COLUMN_SIZE, doc.size)
//                 add(Document.COLUMN_LAST_MODIFIED, doc.updatedAt)
//                 add(
//                     Document.COLUMN_FLAGS,
//                     Document.FLAG_SUPPORTS_OPEN
//                 )
//             }
//         }

//         return cursor
//     }

//     // открытие файла
//     override fun openDocument(
//         documentId: String,
//         mode: String,
//         signal: CancellationSignal?
//     ): ParcelFileDescriptor {

//         val doc = db.getDocument(documentId)
//             ?: throw FileNotFoundException()

//         val file = File(doc.filePath)

//         return ParcelFileDescriptor.open(
//             file,
//             ParcelFileDescriptor.MODE_READ_ONLY
//         )
//     }
// }
