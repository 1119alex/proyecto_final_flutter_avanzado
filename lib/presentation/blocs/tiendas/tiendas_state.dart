import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class TiendasState extends Equatable {
  const TiendasState();

  @override
  List<Object?> get props => [];
}

class TiendasInitial extends TiendasState {
  const TiendasInitial();
}

class TiendasLoading extends TiendasState {
  const TiendasLoading();
}

class TiendasLoaded extends TiendasState {
  final List<Tienda> tiendas;

  const TiendasLoaded(this.tiendas);

  @override
  List<Object?> get props => [tiendas];
}

class TiendasError extends TiendasState {
  final String message;

  const TiendasError(this.message);

  @override
  List<Object?> get props => [message];
}

class TiendaCreated extends TiendasState {
  const TiendaCreated();
}

class TiendaUpdated extends TiendasState {
  const TiendaUpdated();
}

class TiendaDeleted extends TiendasState {
  const TiendaDeleted();
}
