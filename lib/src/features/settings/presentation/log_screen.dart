import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_documents/src/sevices/observer.dart';

import '../../../utils/page_transition/app_page_route.dart';

class LogScreen extends StatefulWidget {
  static PageRoute route() => AppPageRoute.build(
    page: LogScreen(),
    transition: PageTransitionType.slideFromRight,
  );
  
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<LogEntry> _logs = [];
  LogLevel _selectedLevel = LogLevel.verbose;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _logs = SessionLogger.instance.getLogs();
  }

  List<LogEntry> get _filteredLogs {
    return _logs.reversed.where((log) {
      final matchesLevel = _selectedLevel == LogLevel.verbose || 
          log.level.index >= _selectedLevel.index;
      final matchesCategory = _selectedCategory == null || 
          log.category == _selectedCategory;
      final matchesSearch = _searchController.text.isEmpty ||
          log.message.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          log.category.toLowerCase().contains(_searchController.text.toLowerCase());
      
      return matchesLevel && matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get _availableCategories {
    return _logs
        .map((log) => log.category)
        .toSet()
        .toList()
      ..sort();
  }

  Color _getLevelColor(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => Colors.grey.shade600,
      LogLevel.debug => Colors.blue,
      LogLevel.info => Colors.green,
      LogLevel.warning => Colors.orange,
      LogLevel.error => Colors.red,
      LogLevel.fatal => Colors.red.shade900,
    };
  }

  IconData _getLevelIcon(LogLevel level) {
    return switch (level) {
      LogLevel.verbose => Icons.list,
      LogLevel.debug => Icons.bug_report,
      LogLevel.info => Icons.info,
      LogLevel.warning => Icons.warning,
      LogLevel.error => Icons.error,
      LogLevel.fatal => Icons.crisis_alert,
    };
  }

  void _clearLogs() {
    setState(() {
       SessionLogger.instance.clearLogs();
    });
  }

  void _copyToClipboard() {
    final text = _filteredLogs.map((log) => log.toString()).join('\n');
   Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Логи скопированы в буфер обмена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Логи сессии'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Скопировать логи',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
            tooltip: 'Очистить логи',
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтры
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Поиск
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по логам...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                // Фильтры по уровню и категории
                Row(
                  spacing: 5,
                  children: [
                    // Фильтр по уровню
                    Expanded(
                      child: DropdownButtonFormField<LogLevel>(
                        initialValue: _selectedLevel,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Уровень',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: LogLevel.values.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Row(
                              children: [
                                Icon(
                                  _getLevelIcon(level),
                                  color: _getLevelColor(level),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(level.name.toUpperCase()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value!;
                          });
                        },
                      ),
                    ),
                    // Фильтр по категории
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Все категории', overflow: TextOverflow.ellipsis,),
                          ),
                          ..._availableCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Счетчик логов
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Логов: ${_filteredLogs.length}/${_logs.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_searchController.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: Text(
                      'Очистить поиск',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          // Список логов
          Expanded(
            child: _filteredLogs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Логов не найдено'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      final showTime = index == 0 ||
                          _filteredLogs[index - 1].timestamp.day != 
                          log.timestamp.day;

                      return Column(
                        children: [
                          // Разделитель по дням
                          if (showTime)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              color: Colors.grey.shade200,
                              child: Row(
                                children: [
                                  Text(
                                    '${log.timestamp.day}.${log.timestamp.month}.${log.timestamp.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Запись лога
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _getLevelColor(log.level).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getLevelIcon(log.level),
                                color: _getLevelColor(log.level),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              log.category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getLevelColor(log.level),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.message),
                                const SizedBox(height: 2),
                                Text(
                                  '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (log.extra != null && log.extra!.isNotEmpty)
                                  Text(
                                    'Extra: ${log.extra!.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: log.error != null
                                ? const Icon(Icons.error_outline, color: Colors.red)
                                : null,
                            onTap: () {
                              // Детальный просмотр лога
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        _getLevelIcon(log.level),
                                        color: _getLevelColor(log.level),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(log.category),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SelectableText(
                                          log.message,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Время: ${log.timestamp.toIso8601String()}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (log.extra != null && log.extra!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Дополнительные данные:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SelectableText(log.extra.toString()),
                                        ],
                                        if (log.error != null) ...[
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Ошибка:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          SelectableText(log.error.toString()),
                                        ],
                                        if (log.stackTrace != null) ...[
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Stack trace:',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SelectableText(
                                            log.stackTrace.toString(),
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Закрыть'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        tooltip: 'В начало',
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}
