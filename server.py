from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Расписание занятий (время начала и название предмета)
schedule = []


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    print(username,password)
    # Проверка учетных данных
    if username == 'admin' and password == 'admin':
        return jsonify({'success': True}), 200
    else:
        return jsonify({'success': False, 'message': 'Invalid username or password'}), 401


@app.route('/schedule', methods=['GET'])
def get_schedule():
    return jsonify(schedule), 200


@app.route('/schedule', methods=['POST'])
def add_subject():
    data = request.get_json()
    lesson = data.get('lesson')
    time = data.get('time')

    # Проверка, чтобы не добавлять предметы с одинаковым временем
    for subject in schedule:
        if subject['time'] == time:
            return jsonify({'success': False, 'message': 'Time slot is already taken'}), 400

    schedule.append({'lesson': lesson, 'time': time})
    print('sch+',schedule)
    return jsonify({'success': True}), 201


@app.route('/schedule/<int:index>', methods=['DELETE'])
def delete_subject(index):
    print('sch-',schedule)
    if 0 <= index < len(schedule):
        del schedule[index]
        return jsonify({'success': True}), 200
    else:
        return jsonify({'success': False, 'message': 'Index out of range'}), 404


if __name__ == '__main__':
    app.run(debug=True)
