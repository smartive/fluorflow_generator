import 'package:analyzer/dart/constant/value.dart';

TEnum getEnumFromAnnotation<TEnum extends Enum>(
    List<TEnum> values, DartObject enumField,
    [TEnum? defaultValue]) {
  final index = enumField.getField('index')?.toIntValue();
  if (index == null && defaultValue != null) {
    return defaultValue;
  }
  return values[index ?? 0];
}
