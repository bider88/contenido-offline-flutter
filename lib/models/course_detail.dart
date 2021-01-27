import 'dart:convert';

import 'package:content_offline/models/content.dart';

Course courseDetailFromJson(String str) => Course.fromJson(json.decode(str));

String courseDetailToJson(Course data) => json.encode(data.toJson());

class Course {
  Course({
    this.id,
    this.nombre,
    this.duracion,
    this.descripcion,
    this.autor,
    this.puntosOtrogados,
    this.tieneEvaluacion,
    this.ranking,
    this.avance,
    this.calificacion,
    this.calificacionMinimaRequerida,
    this.estatus,
    this.imagen,
    this.fechaLimite,
    this.intentosEvaluacion,
    this.idTipoCurso,
    this.tipoCurso,
    this.tieneEncuesta,
    this.encuestaRespondida,
    this.contenidos,
    this.observaciones,
  });

  int id;
  String nombre;
  String duracion;
  String descripcion;
  String autor;
  int puntosOtrogados;
  bool tieneEvaluacion;
  double ranking;
  int avance;
  int calificacion;
  int calificacionMinimaRequerida;
  int estatus;
  String imagen;
  String fechaLimite;
  int intentosEvaluacion;
  int idTipoCurso;
  String tipoCurso;
  bool tieneEncuesta;
  bool encuestaRespondida;
  List<Content> contenidos;
  String observaciones;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["id"],
    nombre: json["nombre"],
    duracion: json["duracion"],
    descripcion: json["descripcion"],
    autor: json["autor"],
    puntosOtrogados: json["puntosOtrogados"],
    tieneEvaluacion: json["tieneEvaluacion"],
    ranking: json["ranking"],
    avance: json["avance"],
    calificacion: json["calificacion"],
    calificacionMinimaRequerida: json["calificacionMinimaRequerida"],
    estatus: json["estatus"],
    imagen: json["imagen"],
    fechaLimite: json["fechaLimite"],
    intentosEvaluacion: json["intentosEvaluacion"],
    idTipoCurso: json["idTipoCurso"],
    tipoCurso: json["tipoCurso"],
    tieneEncuesta: json["tieneEncuesta"],
    encuestaRespondida: json["encuestaRespondida"],
    contenidos: List<Content>.from(json["contenidos"].map((x) => Content.fromJson(x))),
    observaciones: json["observaciones"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "duracion": duracion,
    "descripcion": descripcion,
    "autor": autor,
    "puntosOtrogados": puntosOtrogados,
    "tieneEvaluacion": tieneEvaluacion,
    "ranking": ranking,
    "avance": avance,
    "calificacion": calificacion,
    "calificacionMinimaRequerida": calificacionMinimaRequerida,
    "estatus": estatus,
    "imagen": imagen,
    "fechaLimite": fechaLimite,
    "intentosEvaluacion": intentosEvaluacion,
    "idTipoCurso": idTipoCurso,
    "tipoCurso": tipoCurso,
    "tieneEncuesta": tieneEncuesta,
    "encuestaRespondida": encuestaRespondida,
    "contenidos": List<dynamic>.from(contenidos.map((x) => x.toJson())),
    "observaciones": observaciones,
  };
}
