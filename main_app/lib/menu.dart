import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit.dart';

class Subject {
  final String lesson;
  final String time;

  Subject(this.lesson, this.time);
}

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Subject> scheduleList = [];

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/schedule'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          scheduleList = data.map((item) => Subject(item['lesson'], item['time'])).toList();
        });
      } else {
        // Обработка ошибок, если сервер вернул ошибочный статус код
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка'),
            content: Text('Не удалось загрузить расписание'),
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
          content: Text('Произошла ошибка при загрузке расписания'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание'),
      ),
      body: ListView.builder(
        itemCount: scheduleList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(scheduleList[index].lesson),
            subtitle: Text(scheduleList[index].time),
            onTap: () {
              _navigateToEditPage(scheduleList[index]);
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteSubject(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToEditPage(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void _updateScheduleList(List<Subject> updatedList) {
    setState(() {
      scheduleList = updatedList;
    });
  }
  void _navigateToEditPage(Subject? subject) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(
          subject: subject,
          scheduleList: scheduleList,
          updateScheduleList: _updateScheduleList,
        ),
      ),
    );

    // Определите функцию обратного вызова для обновления scheduleList


    if (result != null) {
      if (subject != null) {
        int index = scheduleList.indexOf(subject);
        setState(() {
          scheduleList[index] = result;
        });
      } else {
        setState(() {
          scheduleList.add(result);
        });
      }
    }
  }

  Future<void> _deleteSubject(int index) async {
    try {
      final response = await http.delete(Uri.parse('http://127.0.0.1:5000/schedule/$index'));

      if (response.statusCode == 200) {
        setState(() {
          scheduleList.removeAt(index);
        });
      } else {
        // Обработка ошибок, если сервер вернул ошибочный статус код
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка'),
            content: Text('Не удалось удалить предмет из расписания'),
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
          content: Text('Произошла ошибка при удалении предмета из расписания'),
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