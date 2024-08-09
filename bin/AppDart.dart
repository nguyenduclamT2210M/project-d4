import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';

Future<void> main() async {
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'student_db',

  ));

  // Tạo file JSON nếu chưa tồn tại
  final file = File('Student.json');
  if (!await file.exists()) {
    await file.writeAsString(jsonEncode([]));
  }

  while (true) {
    print('\nChọn chức năng:');
    print('1. Hiển thị toàn bộ sinh viên');
    print('2. Thêm sinh viên');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên theo tên hoặc ID');
    print('5. Hiển thị sinh viên có điểm thi môn cao nhất');
    print('6. Thoát');
    print("Lựa chọn của bạn là: ");

    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await displayAllStudents();
        break;
      case '2':
        await addStudent();
        break;
      case '3':
        await updateStudent();
        break;
      case '4':
        await searchStudent();
        break;
      case '5':
        await displayTopScoringStudents();
        break;
      case '6':
        print('Thoát chương trình.');
        await conn.close();
        return;
      default:
        print('Lựa chọn không hợp lệ. Vui lòng chọn lại.');
    }
  }
}


Future<void> displayAllStudents() async {
  final file = File('Student.json');
  final contents = await file.readAsString();
  final List<dynamic> students = jsonDecode(contents);

  for (var student in students) {
    print('ID: ${student['ID']}');
    print('Tên: ${student['Name']}');
    for (var subject in student['Subjects']) {
      print('Môn: ${subject['SubjectName']}, Điểm: ${subject['Score']}');
    }
    print('---------------------');
  }
}


Future<void> addStudent() async {
  final file = File('Student.json');
  final contents = await file.readAsString();
  final List<dynamic> students = jsonDecode(contents);

  print('Nhập ID sinh viên:');

  final id = stdin.readLineSync();


  print('Nhập tên sinh viên:');
  final name = stdin.readLineSync();

  final subjects = <Map<String, dynamic>>[];
  while (true) {
    print('Nhập tên môn học (hoặc gõ "xong" để kết thúc):');
    final subjectName = stdin.readLineSync();
    if (subjectName?.toLowerCase() == 'xong') break;

    print('Nhập điểm môn học:');
    final score = double.parse(stdin.readLineSync()!);

    subjects.add({'SubjectName': subjectName, 'Score': score});
  }

  students.add({'ID': id, 'Name': name, 'Subjects': subjects});
  await file.writeAsString(jsonEncode(students));
  print("Thêm sinh viên thành công!!!!");
}


Future<void> updateStudent() async {
  final file = File('Student.json');
  final contents = await file.readAsString();
  final List<dynamic> students = jsonDecode(contents);

  print('Nhập ID sinh viên cần sửa:');
  final id = stdin.readLineSync();

  final student = students.firstWhere((s) => s['ID'] == id, orElse: () => null);
  if (student == null) {
    print('Sinh viên không tồn tại.');
    return;
  }

  print('Nhập tên mới (để bỏ qua, nhấn Enter):');
  final name = stdin.readLineSync();
  if (name != null && name.isNotEmpty) {
    student['Name'] = name;
  }

  final subjects = <Map<String, dynamic>>[];
  while (true) {
    print('Nhập tên môn học (hoặc gõ "xong" để kết thúc):');
    final subjectName = stdin.readLineSync();
    if (subjectName?.toLowerCase() == 'xong') break;

    print('Nhập điểm môn học:');
    final score = double.parse(stdin.readLineSync()!);

    subjects.add({'SubjectName': subjectName, 'Score': score});
  }

  student['Subjects'] = subjects;
  await file.writeAsString(jsonEncode(students));
  print("Sửa sinh viên thành công!!!!");
}


Future<void> searchStudent() async {
  final file = File('Student.json');
  final contents = await file.readAsString();
  final List<dynamic> students = jsonDecode(contents);

  print('Nhập tên hoặc ID sinh viên để tìm kiếm:');
  final searchTerm = stdin.readLineSync();

  final result = students.where((s) => s['Name'] == searchTerm || s['ID'] == searchTerm).toList();
  if (result.isEmpty) {
    print('Không tìm thấy sinh viên.');
  } else {
    for (var student in result) {
      print('ID: ${student['ID']}');
      print('Tên: ${student['Name']}');
      for (var subject in student['Subjects']) {
        print('Môn: ${subject['SubjectName']}, Điểm: ${subject['Score']}');
      }
      print('----------------------');
    }
  }
}


Future<void> displayTopScoringStudents() async {
  final file = File('Student.json');
  final contents = await file.readAsString();
  final List<dynamic> students = jsonDecode(contents);

  print('Nhập tên môn học để tìm điểm cao nhất:');
  final subjectName = stdin.readLineSync();

  double maxScore = -1;
  final topStudents = <Map<String, dynamic>>[];

  for (var student in students) {
    for (var subject in student['Subjects']) {
      if (subject['SubjectName'] == subjectName) {
        final score = subject['Score'];
        if (score > maxScore) {
          maxScore = score;
          topStudents.clear();
          topStudents.add(student);
        } else if (score == maxScore) {
          topStudents.add(student);
        }
      }
    }
  }

  if (topStudents.isEmpty) {
    print('Không có sinh viên nào có điểm môn học này.');
  } else {
    for (var student in topStudents) {
      print('ID: ${student['ID']}');
      print('Tên: ${student['Name']}');
      print('Điểm cao nhất: $maxScore');
      print('----------------------');
    }
  }
}
