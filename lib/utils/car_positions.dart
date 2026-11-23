import 'package:lumadrive_control/generated/mesh.pb.dart';

const carPositionLabels = <CarPosition, String>{
  CarPosition.REAR_LEFT_DOOR: 'Rear left door',
  CarPosition.REAR_LEFT_POCKET: 'Rear left door pocket',
  CarPosition.REAR_LEFT_HANDLE: 'Rear left door handle',
  CarPosition.REAR_LEFT_FOOTWELL: 'Rear left footwell',
  CarPosition.FRONT_LEFT_DOOR: 'Front left door',
  CarPosition.FRONT_LEFT_POCKET: 'Front left door pocket',
  CarPosition.FRONT_LEFT_HANDLE: 'Front left door handle',
  CarPosition.FRONT_LEFT_FOOTWELL: 'Front left footwell',
  CarPosition.CONSOLE_LEFT: 'Center console · left',
  CarPosition.DASH_LEFT: 'Dash · left',
  CarPosition.DASH_RIGHT: 'Dash · right',
  CarPosition.CONSOLE_RIGHT: 'Center console · right',
  CarPosition.FRONT_RIGHT_FOOTWELL: 'Front right footwell',
  CarPosition.FRONT_RIGHT_HANDLE: 'Front right door handle',
  CarPosition.FRONT_RIGHT_POCKET: 'Front right door pocket',
  CarPosition.FRONT_RIGHT_DOOR: 'Front right door',
  CarPosition.REAR_RIGHT_FOOTWELL: 'Rear right footwell',
  CarPosition.REAR_RIGHT_HANDLE: 'Rear right door handle',
  CarPosition.REAR_RIGHT_POCKET: 'Rear right door pocket',
  CarPosition.REAR_RIGHT_DOOR: 'Rear right door',
};

String suggestedNodeName(CarPosition position) {
  for (final entry in carDoorParts.entries) {
    if (entry.value.contains(position)) {
      return carPositionLabels[entry.key]!
          .replaceAll(' left ', ' L ')
          .replaceAll(' right ', ' R ');
    }
  }
  return (carPositionLabels[position] ?? 'Node')
      .replaceAll(' · left', ' L')
      .replaceAll(' · right', ' R')
      .replaceAll(' left ', ' L ')
      .replaceAll(' right ', ' R ');
}

const carDoorParts = <CarPosition, List<CarPosition>>{
  CarPosition.REAR_LEFT_DOOR: [
    CarPosition.REAR_LEFT_DOOR,
    CarPosition.REAR_LEFT_HANDLE,
    CarPosition.REAR_LEFT_POCKET,
  ],
  CarPosition.FRONT_LEFT_DOOR: [
    CarPosition.FRONT_LEFT_DOOR,
    CarPosition.FRONT_LEFT_HANDLE,
    CarPosition.FRONT_LEFT_POCKET,
  ],
  CarPosition.FRONT_RIGHT_DOOR: [
    CarPosition.FRONT_RIGHT_DOOR,
    CarPosition.FRONT_RIGHT_HANDLE,
    CarPosition.FRONT_RIGHT_POCKET,
  ],
  CarPosition.REAR_RIGHT_DOOR: [
    CarPosition.REAR_RIGHT_DOOR,
    CarPosition.REAR_RIGHT_HANDLE,
    CarPosition.REAR_RIGHT_POCKET,
  ],
};
