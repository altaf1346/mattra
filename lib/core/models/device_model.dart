class DeviceModel {
  final String id;
  final String name;
  final bool isBle;
  final int rssi;

  DeviceModel({
    required this.id,
    required this.name,
    required this.isBle,
    required this.rssi,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isBle': isBle,
    'rssi': rssi,
  };

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: json['id'] as String,
    name: json['name'] as String,
    isBle: json['isBle'] as bool,
    rssi: json['rssi'] as int,
  );

  @override
  String toString() => 'DeviceModel(id: $id, name: $name, isBle: $isBle, rssi: $rssi)';
}