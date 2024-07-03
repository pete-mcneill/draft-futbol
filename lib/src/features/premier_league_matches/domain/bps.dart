class Bps {
  int? element;
  int? value;

  Bps({this.element, this.value});

  factory Bps.fromJson(Map<String, dynamic> json) {
    return Bps(element: json['element'], value: json['value']);
  }
}
