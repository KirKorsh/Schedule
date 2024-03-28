import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'menu.dart';

class EditPage extends StatefulWidget {
  final Subject? subject;
  final List<Subject> scheduleList;
  final Function(List<Subject>) updateScheduleList;

  EditPage({this.subject, required this.scheduleList, required this.updateScheduleList});

  @override
  _EditPageState createState() => _EditPageState();
}



class _EditPageState extends State<EditPage> {
  TextEditingController _lessonController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _lessonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _lessonController,
              decoration: InputDecoration(
                labelText: 'Предмет',
              ),
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text('Время'),
              subtitle: Text('${_selectedTime.format(context)}'),
              onTap: _selectTime,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveSubject,
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveSubject() async {
    String lesson = _lessonController.text;
    String time =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    // Отправка данных нового предмета на сервер
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/schedule'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'lesson': lesson,
        'time': time,
      }),
    );

    if (response.statusCode == 201) {
      // Обновляем список расписания в MenuPage, используя функцию обратного вызова
      //widget.updateScheduleList(widget.scheduleList);
      Navigator.pop(context);
      await _fetchAndUpdateSchedule();

    } else {
      // Обработка ошибки, если данные не удалось добавить на сервер
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Не удалось добавить предмет на сервер'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  Future<void> _fetchAndUpdateSchedule() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/schedule'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Subject> updatedScheduleList = data.map((item) => Subject(item['lesson'], item['time'])).toList();

        // Обновляем состояние в меню
        widget.updateScheduleList(updatedScheduleList);
      } else {
        // Обработка ошибок, если сервер вернул ошибочный статус код
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка'),
            content: Text('Не удалось обновить расписание'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Обработка ошибок, если запрос завершился неудачно
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Произошла ошибка при обновлении расписания'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

}
