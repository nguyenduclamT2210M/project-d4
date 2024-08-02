import 'dart:typed_data';
import 'package:mysql1/mysql1.dart';
import 'dart:io';

class Student {
  int id;
  String name; // field
  String phone;
  Student({required this.id, required this.name, required this.phone}); // constructor
}

class DatabaseHelper {
  final ConnectionSettings settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    // password: ''
    db: 'school',
    timeout: Duration(seconds: 30), // Thoi gian cho ket noi
  );

  Future<MySqlConnection> getConnection() async {
    try {
      return await MySqlConnection.connect(settings); // return connection object
    } catch (e) {
      print('Không thể kết nối tới Database');
      rethrow;
    }
  }

  Future<void> createStudent(Student student) async {
    MySqlConnection? conn; // Tao doi tuong kieu MySqlConnection
    conn = await getConnection();
    await conn.query('insert into Student(name,phone) values(?,?)', [student.name, student.phone]);
  }

  Future<List<Student>> getStudents() async {
    MySqlConnection? conn;
    conn = await getConnection();
    var results = await conn.query("select * from Student");
    List<Student> students = [];
    for (var row in results) {
      students.add(Student(id: row[0], name: row[1], phone: row[2]));
    }
    return students;
  }

  Future<void> deleteStudent(int id) async {
    MySqlConnection? conn;
    conn = await getConnection();
    await conn.query('delete from Student where id = ?', [id]);
  }

  Future<void> updateStudent(Student student) async {
    MySqlConnection? conn;
    conn = await getConnection();
    await conn.query('update Student set name = ?, phone =? where id = ?', [student.name, student.phone, student.id]);
  }
}

void displayMenu() {
  print('--- Menu ---');
  print('1. Thêm sinh viên mới');
  print('2. Hiển thị danh sách sinh viên');
  print('3. Cập nhật thông tin sinh viên');
  print('4. Xóa sinh viên');
  print('5. Thoát');
  print('Chọn một tùy chọn: ');
}

Future<void> main() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  bool running = true;

  while (running) {
    displayMenu();
    int? choice = int.tryParse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        print('Nhập tên sinh viên: ');
        String name = stdin.readLineSync()!;
        print('Nhập số điện thoại sinh viên: ');
        String phone = stdin.readLineSync()!;
        Student newStudent = Student(id: 0, name: name, phone: phone);
        await dbHelper.createStudent(newStudent);
        print('Đã thêm sinh viên mới');
        break;
      case 2:
        List<Student> students = await dbHelper.getStudents();
        for (var student in students) {
          print('${student.id} - ${student.name} - ${student.phone}');
        }
        break;
      case 3:
        print('Nhập ID sinh viên cần cập nhật: ');
        int id = int.parse(stdin.readLineSync()!);
        print('Nhập tên mới của sinh viên: ');
        String newName = stdin.readLineSync()!;
        print('Nhập số điện thoại mới của sinh viên: ');
        String newPhone = stdin.readLineSync()!;
        Student updatedStudent = Student(id: id, name: newName, phone: newPhone);
        await dbHelper.updateStudent(updatedStudent);
        print('Đã cập nhật thông tin sinh viên');
        break;
      case 4:
        print('Nhập ID sinh viên cần xóa: ');
        int id = int.parse(stdin.readLineSync()!);
        await dbHelper.deleteStudent(id);
        print('Đã xóa sinh viên');
        break;
      case 5:
        running = false;
        break;
      default:
        print('Lựa chọn không hợp lệ, vui lòng chọn lại.');
    }
  }
  print('Thoát chương trình.');
}
