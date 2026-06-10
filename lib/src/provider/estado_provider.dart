import 'package:get_storage/get_storage.dart';
import 'package:asistencia_vial_app/src/environment/environment.dart';
import 'package:asistencia_vial_app/src/models/usuario.dart';
import 'package:get/get.dart';

import '../models/estado.dart';
import 'base_provider.dart';

class EstadoProvider extends BaseProvider {
  String url = Environment.API_URL + "api/estados";
  Usuario get usuario => Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<List<Estado>> getAll() async {
    Response response = await get('$url/getall', headers: {
      'Content-type': 'application/json',
      'Authorization': usuario.sessionToken ?? ''
    });

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No tienes acceso a esta información');
      return [];
    }

    List<Estado> estados = Estado.fromJsonList(response.body);
    return estados;
  }
}
