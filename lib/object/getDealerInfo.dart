class DealerInfo {
  int id;
  String name, phone, address, postcode, city, state, country;

  DealerInfo(
      {this.id,
      this.name,
        this.phone,
      this.address,
      this.postcode,
      this.city,
      this.state,
      this.country});

  factory DealerInfo.fromJson(Map<String, dynamic> json) {
    return DealerInfo(
        id: json['dealer_id'],
        name: json['name'],
        phone: json['phone'],
        address: json['address1'],
        postcode: json['postcode'],
        city: json['city'],
        state: json['state'],
        country: json["country"]);
  }
}
