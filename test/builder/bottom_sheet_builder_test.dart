import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:fluorflow_generator/src/builder/bottom_sheet_builder.dart';
import 'package:test/test.dart';

void main() {
  group('BottomSheetBuilder', () {
    test(
        'should not generate something when no input is given.',
        () => testBuilder(BottomSheetBuilder(BuilderOptions.empty), {},
            outputs: {}));

    test(
        'should not generate something when no subclasses for bottom sheets are present.',
        () => testBuilder(BottomSheetBuilder(BuilderOptions.empty), {
              'a|lib/a.dart': '''
                class View {}
              '''
            }, outputs: {}));

    group('for FluorFlowSimpleBottomSheet', () {
      test(
          'should generate sheet method for dynamic return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method for void return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet<void> {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, void)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, void), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, null));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method for core return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet<String> {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, String?)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, String?), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method for library return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                import 'b.dart';

                class MySheet extends FluorFlowSimpleBottomSheet<DialogResultType> {
                  const MySheet({super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                class DialogResultType {}
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i3;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i2;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, _i2.DialogResultType?)> showMySheet({
    _i3.Color barrierColor = const _i3.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, _i2.DialogResultType?), _i4.MySheet>(
        _i4.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('for FluorFlowBottomSheet', () {
      test(
          'should generate sheet method for dynamic return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowBottomSheet<dynamic, MyViewModel> {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method for void return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowBottomSheet<void, MyViewModel> {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, void)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, void), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, null));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method for core return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowBottomSheet<String, MyViewModel> {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, String?)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, String?), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method for library return type.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                import 'b.dart';

                class MySheet extends FluorFlowBottomSheet<DialogResultType, MyViewModel> {
                  const MySheet({super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                class DialogResultType {}
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i3;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i2;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, _i2.DialogResultType?)> showMySheet({
    _i3.Color barrierColor = const _i3.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, _i2.DialogResultType?), _i4.MySheet>(
        _i4.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('for Bottom Sheet with parameters', () {
      test(
          'should generate sheet method with required positional argument.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  final String pos;
                  const MySheet(this.pos, {super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
    required String pos,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(
          pos,
          completer: closeSheet,
        ),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method with required nullable positional argument.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  final String? pos;
                  const MySheet(this.pos, {super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
    required String? pos,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(
          pos,
          completer: closeSheet,
        ),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method with required named argument.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  final String pos;
                  const MySheet({required this.pos, super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
    required String pos,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(
          completer: closeSheet,
          pos: pos,
        ),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method with an optional named argument.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  final String? pos;
                  const MySheet({this.pos, super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
    String? pos,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(
          completer: closeSheet,
          pos: pos,
        ),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method with a defaulted named argument.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  final String pos;
                  const MySheet({this.pos = 'default', super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
    String pos = 'default',
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(
          completer: closeSheet,
          pos: pos,
        ),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate sheet method with external referenced argument.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                import 'b.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  final MySheetRef pos;
                  const MySheet({required this.pos, super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                class MySheetRef {}
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
    required _i3.MySheetRef pos,
  }) =>
      showBottomSheet<(bool?, dynamic), _i4.MySheet>(
        _i4.MySheet(
          completer: closeSheet,
          pos: pos,
        ),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('with @BottomSheetConfig()', () {
      test(
          'should generate sheet method with custom default options.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/annotations.dart';
                import 'package:fluorflow/fluorflow.dart';

                @BottomSheetConfig(
                  defaultBarrierColor: 0x34ff0000,
                  defaultFullscreen: true,
                  defaultDraggable: false,
                )
                class MySheet extends FluorFlowSimpleBottomSheet {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.bottom_sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x34ff0000),
    bool fullscreen = true,
    bool draggable = false,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('with Builder Configuration', () {
      test(
          'should use custom output if configured.',
          () async => await testBuilder(
              BottomSheetBuilder(BuilderOptions({
                'output': 'lib/app/my.sheets.dart',
              })),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MySheet extends FluorFlowSimpleBottomSheet {
                  const MySheet({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app/my.sheets.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension BottomSheets on _i1.BottomSheetService {
  Future<(bool?, dynamic)> showMySheet({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    bool fullscreen = false,
    bool draggable = true,
  }) =>
      showBottomSheet<(bool?, dynamic), _i3.MySheet>(
        _i3.MySheet(completer: closeSheet),
        barrierColor: barrierColor,
        fullscreen: fullscreen,
        draggable: draggable,
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });
  });
}
