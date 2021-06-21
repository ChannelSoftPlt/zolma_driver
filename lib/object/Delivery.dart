class Delivery {
  int id, dealerid, driverid, status, urgent, identify;
  double collection;
  String deliverycode,
      pickupgps,
      remark,
      picture,
      name,
      note,
      signature,
      type,
      systemcode,
      notephoto;

  Delivery(
      {this.id,
        this.deliverycode,
        this.systemcode,
        this.driverid,
        this.pickupgps,
        this.remark,
        this.status,
        this.dealerid,
        this.picture,
        this.notephoto,
        this.name,
        this.urgent,
        this.note,
        this.identify,
        this.signature,
        this.collection,
        this.type});

  static double checkDouble(num value) {
    try {
      return value is double ? value : value.toDouble();
    } catch ($e) {
      return 0.00;
    }
  }

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
        id: json['delivery_id'],
        deliverycode: json['deliverycode'],
        systemcode: json['systemcode'],
        driverid: json['pick_up_driver'],
        pickupgps: json["pick_up_gps"],
        remark: json["remark"],
        status: json["status"],
        dealerid: json["dealerid"],
        notephoto: json["note_photo"],
        picture: json["picture_record"],
        name: json["name"],
        urgent: json["urgent"],
        note: json["note"],
        identify: json["identify"],
        signature: json["signature"],
        collection: checkDouble(json['collection']),
        type: json["type"]);
  }

  Map toJson() => {'id': id, 'status': status};
}
