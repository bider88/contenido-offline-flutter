class Content {
  Content({
    this.id,
    this.nombre,
    this.duracion,
    this.estatus,
    this.url,
    this.orden,
    this.fechaInicio,
    this.fechaFin,
    this.nombreLugar,
    this.direccion,
    this.tipo,
    this.avance,
    this.indicadorDeAvance,
    this.descripcion,
  });

  int id;
  String nombre;
  String duracion;
  int estatus;
  String url;
  int orden;
  dynamic fechaInicio;
  dynamic fechaFin;
  dynamic nombreLugar;
  dynamic direccion;
  String tipo;
  int avance;
  dynamic indicadorDeAvance;
  String descripcion;

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    id: json["id"],
    nombre: json["nombre"],
    duracion: json["duracion"],
    estatus: json["estatus"],
    url: json["url"],
    orden: json["orden"],
    fechaInicio: json["fechaInicio"],
    fechaFin: json["fechaFin"],
    nombreLugar: json["nombreLugar"],
    direccion: json["direccion"],
    tipo: json["tipo"],
    avance: json["avance"],
    indicadorDeAvance: json["indicadorDeAvance"],
    descripcion: json["descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "duracion": duracion,
    "estatus": estatus,
    "url": url,
    "orden": orden,
    "fechaInicio": fechaInicio,
    "fechaFin": fechaFin,
    "nombreLugar": nombreLugar,
    "direccion": direccion,
    "tipo": tipo,
    "avance": avance,
    "indicadorDeAvance": indicadorDeAvance,
    "descripcion": descripcion,
  };

  String getContentUrl(){
    return url.startsWith('https') ? url : 'https://wd.brainb.mx/saml/SSO/$url';
  }
}
