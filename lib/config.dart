import 'package:flutter/material.dart';

/// Всё, что нужно менять под себя, лежит в этом файле.

/// Её имя. Если оставить пустым — обращение будет без имени.
const String herName = 'Аружан';

/// Твой username в Telegram без @. Если пусто — она сама выберет чат,
/// в который отправить ответ.
const String telegramUsername = '';

/// Дата и время свидания.
final DateTime dateTime = DateTime(2026, 11, 21, 18, 0);

const String city = 'Астана';

class DateOption {
  const DateOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// Варианты свидания. Чтобы добавить новый — просто допиши элемент в список.
const List<DateOption> dateOptions = [
  DateOption(
    id: 'horses',
    title: 'Конная прогулка',
    subtitle: 'Лошади, снег и горячий чай после',
    icon: Icons.forest_outlined,
  ),
  DateOption(
    id: 'shooting',
    title: 'Тир',
    subtitle: 'Проверим, кто из нас метче',
    icon: Icons.gps_fixed,
  ),
  DateOption(
    id: 'archery',
    title: 'Стрельба из лука',
    subtitle: 'Почувствуем себя Робин Гудами',
    icon: Icons.track_changes,
  ),
  DateOption(
    id: 'pottery',
    title: 'Гончарный мастер-класс',
    subtitle: 'Слепим что-нибудь на память',
    icon: Icons.emoji_food_beverage_outlined,
  ),
];
