class DriverInfo {
  int id;
  String name, password, phone, email;

  DriverInfo({this.id, this.name, this.password, this.phone, this.email});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
        id: json['driver_id'],
        name: json['name'],
        password: json["password"],
        phone: json["phone"],
        email: json["email"]);
  }
}
