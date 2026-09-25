import 'package:flutter/foundation.dart';
import '../admin_models.dart';
import '../admin_repository.dart';

class AdminController<T> extends ChangeNotifier {
  AdminController(this.repository, this.kind);
  final AdminRepository repository;
  final String kind;
  List<T> items = [];
  bool loading = false;
  String? error;
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final x = kind == 'owners'
          ? await repository.owners()
          : kind == 'pets'
          ? await repository.pets()
          : await repository.records(kind);
      items = List<T>.from(x as List);
    } catch (e) {
      error = 'No se pudo cargar la información: $e';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save(T v) async {
    try {
      if (kind == 'owners')
        await repository.saveOwner(v as Owner);
      else if (kind == 'pets')
        await repository.savePet(v as AdminPet);
      else
        await repository.saveRecord(kind, v as AdminRecord);
      await load();
    } catch (e) {
      error = 'No se pudo guardar: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      if (kind == 'owners')
        await repository.deleteOwner(id);
      else if (kind == 'pets')
        await repository.deletePet(id);
      else
        await repository.deleteRecord(kind, id);
      await load();
    } catch (e) {
      error = 'No se pudo eliminar: $e';
      notifyListeners();
      rethrow;
    }
  }
}

class OwnersController extends AdminController<Owner> {
  OwnersController(AdminRepository repository) : super(repository, 'owners');

  Future<void> createClientAccount(Owner owner, String password) async {
    try {
      await repository.createClientAccount(owner, password);
      await load();
    } catch (e) {
      error = 'No se pudo crear la cuenta: $e';
      notifyListeners();
      rethrow;
    }
  }
}

class PetsController extends AdminController<AdminPet> {
  PetsController(AdminRepository repository) : super(repository, 'pets');
}

class AppointmentsController extends AdminController<AdminRecord> {
  AppointmentsController(AdminRepository repository)
    : super(repository, 'citas');
}

class ConsultationsController extends AdminController<AdminRecord> {
  ConsultationsController(AdminRepository repository)
    : super(repository, 'consultas');
}

class TreatmentsController extends AdminController<AdminRecord> {
  TreatmentsController(AdminRepository repository)
    : super(repository, 'tratamientos');
}

class VaccinesController extends AdminController<AdminRecord> {
  VaccinesController(AdminRepository repository) : super(repository, 'vacunas');
}
