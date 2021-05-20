class Delivery {
  int id, dealerid, driverid, status, urgent, identify;
  String deliverycode,
      pickupgps,
      remark,
      picture,
      name,
      note,
      signature,
      type,
      systemcode;

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
        this.name,
        this.urgent,
        this.note,
        this.identify,
        this.signature,
        this.type});

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
        picture: json["picture_record"],
        name: json["name"],
        urgent: json["urgent"],
        note: json["note"],
        identify: json["identify"],
        signature: json["signature"],
        type: json["type"]);
  }

  Map toJson() => {'id': id, 'status': status};
}
