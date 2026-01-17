import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @failedToScan.
  ///
  /// In en, this message translates to:
  /// **'Failed to scan'**
  String get failedToScan;

  /// No description provided for @failedToImport.
  ///
  /// In en, this message translates to:
  /// **'Failed to import'**
  String get failedToImport;

  /// No description provided for @invalidImportFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid Import Format'**
  String get invalidImportFormat;

  /// No description provided for @invalidBackupFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid Backup Format'**
  String get invalidBackupFormat;

  /// No description provided for @corruptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Corrupted Backup'**
  String get corruptedBackup;

  /// No description provided for @title1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to My Documents'**
  String get title1;

  /// No description provided for @description1.
  ///
  /// In en, this message translates to:
  /// **'Secure storage and organization of your personal documents in one place'**
  String get description1;

  /// No description provided for @title2.
  ///
  /// In en, this message translates to:
  /// **'Deadline Tracking'**
  String get title2;

  /// No description provided for @description2.
  ///
  /// In en, this message translates to:
  /// **'Get notifications about document expiration dates and important events'**
  String get description2;

  /// No description provided for @title3.
  ///
  /// In en, this message translates to:
  /// **'Smart Organization'**
  String get title3;

  /// No description provided for @description3.
  ///
  /// In en, this message translates to:
  /// **'Create folders and document bundles for easy access and management'**
  String get description3;

  /// No description provided for @title4.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get title4;

  /// No description provided for @description4.
  ///
  /// In en, this message translates to:
  /// **'Your documents are protected with modern encryption methods and stored locally'**
  String get description4;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get start;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @moto.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is our priority. We continue to improve the protection of your data.'**
  String get moto;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @paragraph1.
  ///
  /// In en, this message translates to:
  /// **'1. Data Collection'**
  String get paragraph1;

  /// No description provided for @content1.
  ///
  /// In en, this message translates to:
  /// **'The My Documents app collects and stores only the documents that you explicitly upload to the app. We do not collect your personal data without your consent.'**
  String get content1;

  /// No description provided for @paragraph2.
  ///
  /// In en, this message translates to:
  /// **'2. Local Storage'**
  String get paragraph2;

  /// No description provided for @content2.
  ///
  /// In en, this message translates to:
  /// **'All your documents are stored locally on your device. We do not transfer your files to external servers without your explicit permission.'**
  String get content2;

  /// No description provided for @paragraph3.
  ///
  /// In en, this message translates to:
  /// **'3. Data Encryption'**
  String get paragraph3;

  /// No description provided for @content3.
  ///
  /// In en, this message translates to:
  /// **'Your documents are protected with modern AES-256 encryption. Access to the app is secured with a PIN code or biometric authentication.'**
  String get content3;

  /// No description provided for @paragraph4.
  ///
  /// In en, this message translates to:
  /// **'4. Backups'**
  String get paragraph4;

  /// No description provided for @content4.
  ///
  /// In en, this message translates to:
  /// **'You can create encrypted backups to cloud storage of your choice. Encryption keys are stored only on your device.'**
  String get content4;

  /// No description provided for @paragraph5.
  ///
  /// In en, this message translates to:
  /// **'5. Notifications'**
  String get paragraph5;

  /// No description provided for @content5.
  ///
  /// In en, this message translates to:
  /// **'The app uses local notifications for document deadline reminders. These notifications do not require internet access.'**
  String get content5;

  /// No description provided for @paragraph6.
  ///
  /// In en, this message translates to:
  /// **'6. Consent'**
  String get paragraph6;

  /// No description provided for @content6.
  ///
  /// In en, this message translates to:
  /// **'By using the My Documents app, you agree to this privacy policy and give permission for local storage of your documents.'**
  String get content6;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @langText.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langText;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get chooseAppLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateThisApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get rateThisApp;

  /// No description provided for @otherProjects.
  ///
  /// In en, this message translates to:
  /// **'Other projects'**
  String get otherProjects;

  /// No description provided for @moreProjects.
  ///
  /// In en, this message translates to:
  /// **'More projects from our team!'**
  String get moreProjects;

  /// No description provided for @allDocumentsSize.
  ///
  /// In en, this message translates to:
  /// **'All Documents Size'**
  String get allDocumentsSize;

  /// No description provided for @getAllDocumentsSize.
  ///
  /// In en, this message translates to:
  /// **'Get All Documents Size'**
  String get getAllDocumentsSize;

  /// No description provided for @chooseAppTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose app theme'**
  String get chooseAppTheme;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreFromBackup;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @backupDocuments.
  ///
  /// In en, this message translates to:
  /// **'Backup your documents'**
  String get backupDocuments;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @createPIN.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPIN;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication is not available on this device'**
  String get biometricNotAvailable;

  /// No description provided for @useBiometricsInfo.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID'**
  String get useBiometricsInfo;

  /// No description provided for @biometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// No description provided for @removePIN.
  ///
  /// In en, this message translates to:
  /// **'Remove your PIN protection'**
  String get removePIN;

  /// No description provided for @deletePIN.
  ///
  /// In en, this message translates to:
  /// **'Delete PIN'**
  String get deletePIN;

  /// No description provided for @updatePIN.
  ///
  /// In en, this message translates to:
  /// **'Update your security PIN'**
  String get updatePIN;

  /// No description provided for @changePIN.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePIN;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @setUpPIN.
  ///
  /// In en, this message translates to:
  /// **'Set PIN to secure access'**
  String get setUpPIN;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @forgotPIN.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPIN;

  /// No description provided for @fastAndSecure.
  ///
  /// In en, this message translates to:
  /// **'Fast and Secure'**
  String get fastAndSecure;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a file'**
  String get selectFile;

  /// No description provided for @reachedMaxSize.
  ///
  /// In en, this message translates to:
  /// **'File is too large (max 50 MB)'**
  String get reachedMaxSize;

  /// No description provided for @errorSavingFile.
  ///
  /// In en, this message translates to:
  /// **'Error saving file'**
  String get errorSavingFile;

  /// No description provided for @willDeleteAllVersions.
  ///
  /// In en, this message translates to:
  /// **'This will delete the documents permanently. Including all versions.'**
  String get willDeleteAllVersions;

  /// No description provided for @setExpirationDate.
  ///
  /// In en, this message translates to:
  /// **'Set Expiration Date'**
  String get setExpirationDate;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach File'**
  String get attachFile;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reverseOrder.
  ///
  /// In en, this message translates to:
  /// **'Reverse order'**
  String get reverseOrder;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @noFilter.
  ///
  /// In en, this message translates to:
  /// **'No filter'**
  String get noFilter;

  /// No description provided for @archivated.
  ///
  /// In en, this message translates to:
  /// **'archivated'**
  String get archivated;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'SortBy'**
  String get sortBy;

  /// No description provided for @wrongPIN.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN, try again.'**
  String get wrongPIN;

  /// No description provided for @addFirstDocument.
  ///
  /// In en, this message translates to:
  /// **'Add First Document'**
  String get addFirstDocument;

  /// No description provided for @loadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Loading documents...'**
  String get loadingDocuments;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @enterPIN.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPIN;

  /// No description provided for @pinDeleted.
  ///
  /// In en, this message translates to:
  /// **'PIN deleted'**
  String get pinDeleted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your PIN?'**
  String get deletePinConfirm;

  /// No description provided for @pinUpdated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated successfully'**
  String get pinUpdated;

  /// No description provided for @enterNewPIN.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get enterNewPIN;

  /// No description provided for @enterCurrentPIN.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPIN;

  /// No description provided for @enterYourPIN.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN.'**
  String get enterYourPIN;

  /// No description provided for @invalidPIN.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN, try again.'**
  String get invalidPIN;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed.'**
  String get biometricFailed;

  /// No description provided for @enterPINToAccess.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to access your documents'**
  String get enterPINToAccess;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @dataProtected.
  ///
  /// In en, this message translates to:
  /// **'Your data is securely protected'**
  String get dataProtected;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocument;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add Folder'**
  String get addFolder;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access to your documents'**
  String get quickAccess;

  /// No description provided for @searchDocumentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search documents...'**
  String get searchDocumentsHint;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search...'**
  String get typeToSearch;

  /// No description provided for @noDocumentsFound.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get noDocumentsFound;

  /// No description provided for @unknownFolder.
  ///
  /// In en, this message translates to:
  /// **'Unknown Folder'**
  String get unknownFolder;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents here, yet!'**
  String get noDocumentsYet;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @expiringDocuments.
  ///
  /// In en, this message translates to:
  /// **'Expiring Documents'**
  String get expiringDocuments;

  /// No description provided for @notAvailableOnDesktop.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available on desktop'**
  String get notAvailableOnDesktop;

  /// No description provided for @filesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Selected files not found'**
  String get filesNotFound;

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share files'**
  String get failedToShare;

  /// No description provided for @notImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet'**
  String get notImplemented;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirm;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to perform this action?'**
  String get confirmAction;

  /// No description provided for @documentTitleExists.
  ///
  /// In en, this message translates to:
  /// **'Document with this name already exists'**
  String get documentTitleExists;

  /// No description provided for @folderTitleExists.
  ///
  /// In en, this message translates to:
  /// **'Folder with this name already exists'**
  String get folderTitleExists;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard the changes'**
  String get discardChanges;

  /// No description provided for @noFolder.
  ///
  /// In en, this message translates to:
  /// **'No Folder'**
  String get noFolder;

  /// No description provided for @tapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tapToView;

  /// No description provided for @documentsExpiring.
  ///
  /// In en, this message translates to:
  /// **'document(s) are expiring soon or expired'**
  String get documentsExpiring;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'documents'**
  String get documents;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteItem;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @documentName.
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get documentName;

  /// No description provided for @versionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version History'**
  String get versionHistory;

  /// No description provided for @versions.
  ///
  /// In en, this message translates to:
  /// **'versions'**
  String get versions;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Epires at'**
  String get expiresAt;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @noPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview is not available for this document'**
  String get noPreview;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @functioning.
  ///
  /// In en, this message translates to:
  /// **'functioning'**
  String get functioning;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'expiring soon'**
  String get expiringSoon;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get expired;

  /// No description provided for @fileIsTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large (max 50 MB)'**
  String get fileIsTooLarge;

  /// No description provided for @errorSavirgFile.
  ///
  /// In en, this message translates to:
  /// **'Error saving file'**
  String get errorSavirgFile;

  /// No description provided for @addVersion.
  ///
  /// In en, this message translates to:
  /// **'Add Version'**
  String get addVersion;

  /// No description provided for @versionDetais.
  ///
  /// In en, this message translates to:
  /// **'Version Details'**
  String get versionDetais;

  /// No description provided for @noFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get noFoldersFound;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove File'**
  String get removeFile;

  /// No description provided for @chooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Method'**
  String get chooseMethod;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get chooseFile;

  /// No description provided for @folderDetails.
  ///
  /// In en, this message translates to:
  /// **'Folder Details'**
  String get folderDetails;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select a folder...'**
  String get selectFolder;

  /// No description provided for @addToFolder.
  ///
  /// In en, this message translates to:
  /// **'Add To Folder'**
  String get addToFolder;

  /// No description provided for @addToFavorities.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorities;

  /// No description provided for @documentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document Details'**
  String get documentDetails;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder Name'**
  String get folderName;

  /// No description provided for @selectDocuments.
  ///
  /// In en, this message translates to:
  /// **'Select Documents'**
  String get selectDocuments;

  /// No description provided for @changeDetails.
  ///
  /// In en, this message translates to:
  /// **'Change Details'**
  String get changeDetails;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @uploadDate.
  ///
  /// In en, this message translates to:
  /// **'Upload Date'**
  String get uploadDate;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDate;

  /// No description provided for @noExpiration.
  ///
  /// In en, this message translates to:
  /// **'No expiration'**
  String get noExpiration;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @openExternal.
  ///
  /// In en, this message translates to:
  /// **'Open In External App'**
  String get openExternal;

  /// No description provided for @shareDocument.
  ///
  /// In en, this message translates to:
  /// **'Share Document'**
  String get shareDocument;

  /// No description provided for @uploadNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Upload New Version'**
  String get uploadNewVersion;

  /// No description provided for @manageVersions.
  ///
  /// In en, this message translates to:
  /// **'Manage Versions'**
  String get manageVersions;

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
