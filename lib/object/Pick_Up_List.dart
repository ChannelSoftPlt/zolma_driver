class PickUpList {
  int id, dealerid;
  String deliverycode;

  PickUpList({this.id, this.dealerid, this.deliverycode});

  Map<String, dynamic> toMap() {
    return {'id': id, 'dealerid': dealerid, 'name': deliverycode};
  }
}
