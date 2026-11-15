import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

const _accent = Color(0xFFFF8FA3);
const _bgTop = Color(0xFF2B0F1E);
const _bgBottom = Color(0xFF6A1F3D);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Приглашение',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const InvitePage(),
    );
  }
}

String formatDate(DateTime d) {
  const weekdays = [
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье',
  ];
  const months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
}

String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  int _step = 0;
  final Set<String> _selected = {};
  final _ownIdea = TextEditingController();
  final _comment = TextEditingController();
  final _scroll = ScrollController();

  void _goTo(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _ownIdea.dispose();
    _comment.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _canFinish => _selected.isNotEmpty || _ownIdea.text.trim().isNotEmpty;

  String get _answerText {
    final wishes = [
      for (final o in dateOptions)
        if (_selected.contains(o.id)) o.title,
      if (_ownIdea.text.trim().isNotEmpty) _ownIdea.text.trim(),
    ];
    final comment = _comment.text.trim();
    return [
      'Я согласна!',
      '${formatDate(dateTime)}, ${formatTime(dateTime)}',
      'Хочу: ${wishes.join(', ')}',
      if (comment.isNotEmpty) 'Ещё: $comment',
    ].join('\n');
  }

  Future<void> _send() async {
    // Uri.https кодирует пробелы как «+», а Telegram ждёт %20.
    final text = Uri.encodeComponent(_answerText);
    final uri = Uri.parse(
      telegramUsername.isNotEmpty
          ? 'https://t.me/$telegramUsername?text=$text'
          : 'https://t.me/share/url'
                '?url=${Uri.encodeComponent(Uri.base.origin)}&text=$text',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _answerText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ответ скопирован')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOut,
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: switch (_step) {
                      0 => _buildInvite(),
                      1 => _buildPoll(),
                      _ => _buildDone(),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvite() {
    final days = dateTime.difference(DateTime.now()).inDays;
    final greeting = herName.isEmpty ? 'Привет!' : 'Привет, $herName!';
    return Column(
      children: [
        const Icon(Icons.favorite, color: _accent, size: 56),
        const SizedBox(height: 20),
        Text(greeting, style: _titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text(
          'Я хочу пригласить тебя на свидание',
          style: _bodyStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _Card(
          child: Column(
            children: [
              _InfoRow(icon: Icons.calendar_today, text: formatDate(dateTime)),
              const SizedBox(height: 14),
              _InfoRow(icon: Icons.schedule, text: formatTime(dateTime)),
              const SizedBox(height: 14),
              const _InfoRow(icon: Icons.place_outlined, text: city),
            ],
          ),
        ),
        if (days > 0) ...[
          const SizedBox(height: 14),
          Text(
            'До встречи дней: $days',
            style: _bodyStyle.copyWith(fontSize: 14, color: Colors.white60),
          ),
        ],
        const SizedBox(height: 28),
        const Text('Пойдёшь со мной?', style: _bodyStyle),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: 'Да, с удовольствием',
          onPressed: () => _goTo(1),
        ),
        const _RunawayNoButton(),
      ],
    );
  }

  Widget _buildPoll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Ура! Как проведём вечер?',
          style: _titleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Можно выбрать несколько вариантов',
          style: _bodyStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        for (final o in dateOptions) ...[
          _OptionTile(
            option: o,
            selected: _selected.contains(o.id),
            onTap: () => setState(() {
              if (!_selected.remove(o.id)) _selected.add(o.id);
            }),
          ),
          const SizedBox(height: 12),
        ],
        _Field(
          controller: _ownIdea,
          hint: 'Или свой вариант',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 28),
        _Field(
          controller: _comment,
          hint: 'Пожелания (необязательно)',
          maxLines: 3,
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          label: 'Готово',
          onPressed: _canFinish ? () => _goTo(2) : null,
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.celebration_outlined, color: _accent, size: 56),
        const SizedBox(height: 20),
        const Text(
          'Договорились!',
          style: _titleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Осталось отправить мне свой ответ',
          style: _bodyStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _Card(child: Text(_answerText, style: _bodyStyle.copyWith(height: 1.6))),
        const SizedBox(height: 24),
        _PrimaryButton(label: 'Отправить в Telegram', onPressed: _send),
        const SizedBox(height: 8),
        TextButton(onPressed: _copy, child: const Text('Скопировать ответ')),
        TextButton(
          onPressed: () => _goTo(1),
          child: const Text('Изменить выбор'),
        ),
      ],
    );
  }
}

const _titleStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.w700,
  color: Colors.white,
  height: 1.2,
);

const _bodyStyle = TextStyle(fontSize: 17, color: Colors.white70, height: 1.4);

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _bgTop,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DateOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.16 : 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? _accent : Colors.white.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(option.icon, color: _accent, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? _accent : Colors.white30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Кнопка «Нет», которая убегает от курсора и пальца.
class _RunawayNoButton extends StatefulWidget {
  const _RunawayNoButton();

  @override
  State<_RunawayNoButton> createState() => _RunawayNoButtonState();
}

class _RunawayNoButtonState extends State<_RunawayNoButton> {
  final _random = Random();
  Alignment _alignment = Alignment.center;

  void _run() {
    Alignment next;
    do {
      next = Alignment(
        _random.nextDouble() * 2 - 1,
        _random.nextDouble() * 2 - 1,
      );
    } while ((next.x - _alignment.x).abs() < 0.6);
    setState(() => _alignment = next);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: AnimatedAlign(
        alignment: _alignment,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: MouseRegion(
          onEnter: (_) => _run(),
          child: GestureDetector(
            onTapDown: (_) => _run(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Нет',
                style: TextStyle(fontSize: 16, color: Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
