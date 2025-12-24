import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentPage = 0;

   List<OnboardingItem> _onboardingItems(BuildContext ctx) => [
    OnboardingItem(
      icon: Icons.folder_special_rounded,
      title: ctx.l10n.title1,
      description:ctx.l10n.description1,
      color: Colors.blueAccent,
      gradient: LinearGradient(
        colors: [Colors.blue.shade400, Colors.blueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingItem(
      icon: Icons.notifications_active_rounded,
      title: ctx.l10n.title2,
      description:ctx.l10n.description2,
      color: Colors.green,
      gradient: LinearGradient(
        colors: [Colors.green.shade400, Colors.teal.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingItem(
      icon: Icons.folder_open_rounded,
      title: ctx.l10n.title3,
      description:ctx.l10n.description3,
      color: Colors.orange,
      gradient: LinearGradient(
        colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingItem(
      icon: Icons.security_rounded,
      title: ctx.l10n.title4,
      description:ctx.l10n.description4,
      color: Colors.purple,
      gradient: LinearGradient(
        colors: [Colors.purple.shade400, Colors.deepPurple.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => PrivacyPolicyModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<OnboardingItem> onboardingItems = _onboardingItems(context);
    final isLastPage = currentPage == onboardingItems.length - 1;
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Основной контент
          PageView.builder(
            controller: _controller,
            itemCount: onboardingItems.length,
            onPageChanged: (index) => setState(() => currentPage = index),
            itemBuilder: (context, index) {
              final item = onboardingItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Декоративный элемент
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: item.gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Icon(
                              item.icon,
                              size: 140,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          // Декоративные круги
                          ...List.generate(3, (i) => i).map(
                            (i) => Positioned(
                              top: 20 + i * 30,
                              left: 20 + i * 40,
                              child: Container(
                                width: 60 - i * 15,
                                height: 60 - i * 15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Заголовок
                    Text(
                      item.title,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Описание
                    Text(
                      item.description,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
         
          // Переключение языков
          Positioned(
            top: 24,
            right: 24,
            child: TextButton(
              onPressed: () {
                final locale = (context.deps.settingsCubit.state.locale==Locale('ru')) ?Locale('en'):Locale('ru');
                context.deps.settingsCubit.changeLocale(locale);
              },
             child: Text(context.l10n.langText) 
            ),
          ),
          // Нижняя панель с элементами управления
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Индикатор страниц
                  SmoothPageIndicator(
                    controller: _controller,
                    count: onboardingItems.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: onboardingItems[currentPage].color,
                      dotColor: Colors.grey.shade300,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Кнопка Privacy Policy
                  TextButton(
                    onPressed: () => _showPrivacyPolicy(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.privacy_tip_rounded,
                          color: Colors.grey.shade600,
                        ),
                       Text(context.l10n.privacyPolicy),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (!isLastPage)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _controller.jumpToPage(
                                onboardingItems.length - 1,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              context.l10n.skip,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (!isLastPage) const SizedBox(width: 16),
                      // Кнопка Далее/Начать
                      Expanded(
                        flex: isLastPage ? 2 : 1,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              context.deps.settingsCubit.changeFirstLaunch();
                              debugPrint(
                                context.deps.settingsCubit.state.isFurstLaunch
                                    .toString(),
                              );
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onboardingItems[currentPage].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? context.l10n.start : context.l10n.next,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isLastPage) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Gradient gradient;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });
}

class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_rounded,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          context.l10n.privacyPolicy,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Содержимое
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    spacing: 22,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        context,
                        context.l10n.paragraph1,
                        context.l10n.content1,
                      ),
                      _buildSection(
                        context,
                        context.l10n.paragraph2,
                        context.l10n.content2,
                      ),
                      _buildSection(
                        context,
                        context.l10n.paragraph3,
                        context.l10n.content3,
                      ),
                      _buildSection(
                        context,
                       context.l10n.paragraph4,
                        context.l10n.content4,
                      ),
                      _buildSection(
                        context,
                        context.l10n.paragraph5,
                        context.l10n.content5,
                      ),
                      _buildSection(
                        context,
                        context.l10n.paragraph6,
                        context.l10n.content6,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: Colors.blue.shade700,
                            ),
                            Expanded(
                              child: Text(
                                context.l10n.moto,
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Кнопка закрытия
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child:Text(
                    context.l10n.gotIt,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
