import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

void main() async {
  log('--- PROBANDO FLUJO COMPLETO: LOGIN + TAREAS ---');

  final loginUrl = Uri.parse('http://127.0.0.1:8000/api/v1/login/');
  final tasksUrl = Uri.parse('http://127.0.0.1:8000/api/v1/tareas/');

  try {
    log('1. Intentando login...');
    final loginRes = await http.post(
      loginUrl,
      body: {'username': 'florezyen', 'password': '30530718yf'},
    );

    if (loginRes.statusCode == 200) {
      final token = json.decode(loginRes.body)['token'];
      log('Token obtenido: $token');

      log('2. Consultando tareas con el token...');
      final taskRes = await http.get(
        tasksUrl,
        headers: {'Authorization': 'Token $token'},
      );

      if (taskRes.statusCode == 200) {
        log('Tareas recibidas:');
        log(taskRes.body);
      }
    } else {
      log('Error en login: ${loginRes.body}');
    }
  } catch (e) {
    log('Error: $e');
  }
}
