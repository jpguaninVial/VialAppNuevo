import 'package:get_storage/get_storage.dart';
import 'package:asistencia_vial_app/src/environment/environment.dart';
import 'package:asistencia_vial_app/src/models/usuario.dart';
import 'package:get/get.dart';

import '../models/peaje.dart';
import '../models/response_api.dart';
import 'base_provider.dart';

class PeajeProvider extends BaseProvider {
  String url = Environment.API_URL + "api/peaje";
  Usuario get usuario => Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Future<List<Peaje>> getAll() async {
    Response response = await get('$url/getall', headers: {
      'Content-type': 'application/json',
      'Authorization': usuario.sessionToken ?? ''
    });

    if (response.statusCode == 401) {
      Get.snackbar('Peticion Denegada', 'No tienes acceso a esta información');
      return [];
    }

    List<Peaje> peajes = Peaje.fromJsonList(response.body);
    return peajes;
  }

  Future<ResponseApi> update(Usuario usuario) async {
    Response response = await post('$url/updatePeaje', usuario.toJson(),
        headers: {
          'Content-type': 'application/json',
          'Authorization': usuario.sessionToken ?? ''
        });

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo realizar la peticion');
      return ResponseApi();
    }

    if (response.statusCode == 401) {
      Get.snackbar(
          'Error', 'No se esta autorizado para realizar esta peticion');
      return ResponseApi();
    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);
    return responseApi;
  }
}
