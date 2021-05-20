class Driver {
  int id, sequence, dealerid, deliveryid;
  String name, dealername, phone, email, city;

  Driver({this.id, this.name, this.dealername, this.dealerid, this.phone, this.email, this.deliveryid, this.sequence, this.city});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
        id: json['driver_id'],
        name: json['name'],
        dealername: json["dealername"],
        dealerid: json["dealer_id"],
        phone: json["phone"],
        email: json["email"],
        deliveryid: json["delivery_id"],
        city: json["city"],
        sequence: json["sequence"]);
  }

  Map toJson() => {'id': dealerid, 'sequence': sequence};
}
