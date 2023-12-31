import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:fluorflow/annotations.dart';
import 'package:fluorflow_generator/src/builder/dialog_builder.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group('DialogBuilder', () {
    test(
        'should not generate something when no input is given.',
        () =>
            testBuilder(DialogBuilder(BuilderOptions.empty), {}, outputs: {}));

    test(
        'should not generate something when no subclasses for dialogs are present.',
        () => testBuilder(DialogBuilder(BuilderOptions.empty), {
              'a|lib/a.dart': '''
                class View {}
              '''
            }, outputs: {}));

    group('for FluorFlowSimpleDialog', () {
      test(
          'should generate dialog method for dynamic return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method for void return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog<void> {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, void)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, void)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, null));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method for core return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog<String> {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, String?)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, String?)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method for library return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                import 'b.dart';

                class MyDialog extends FluorFlowSimpleDialog<DialogResultType> {
                  const MyDialog({super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                class DialogResultType {}
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i3;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i2;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, _i2.DialogResultType?)> showMyDialog(
          {_i3.Color barrierColor = const _i3.Color(0x80000000)}) =>
      showDialog<(bool?, _i2.DialogResultType?)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i4.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('for FluorFlowDialog', () {
      test(
          'should generate dialog method for dynamic return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowDialog<dynamic, MyViewModel> {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method for void return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowDialog<void, MyViewModel> {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, void)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, void)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, null));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method for core return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowDialog<String, MyViewModel> {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, String?)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, String?)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method for library return type.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                import 'b.dart';

                class MyDialog extends FluorFlowDialog<DialogResultType, MyViewModel> {
                  const MyDialog({super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                class DialogResultType {}
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i3;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i2;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, _i2.DialogResultType?)> showMyDialog(
          {_i3.Color barrierColor = const _i3.Color(0x80000000)}) =>
      showDialog<(bool?, _i2.DialogResultType?)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i4.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('for Dialog with parameters', () {
      test(
          'should generate dialog method with required positional argument.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  final String pos;
                  const MyDialog(this.pos, {super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    required String pos,
  }) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(
                  pos,
                  completer: closeDialog,
                )),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method with required nullable positional argument.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  final String? pos;
                  const MyDialog(this.pos, {super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    required String? pos,
  }) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(
                  pos,
                  completer: closeDialog,
                )),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method with required named argument.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  final String pos;
                  const MyDialog({required this.pos, super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    required String pos,
  }) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(
                  completer: closeDialog,
                  pos: pos,
                )),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method with an optional named argument.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  final String? pos;
                  const MyDialog({this.pos, super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    String? pos,
  }) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(
                  completer: closeDialog,
                  pos: pos,
                )),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method with a defaulted named argument.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  final String pos;
                  const MyDialog({this.pos = 'default', super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    String pos = 'default',
  }) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(
                  completer: closeDialog,
                  pos: pos,
                )),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method with external referenced argument.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                import 'b.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  final MyDialogRef pos;
                  const MyDialog({required this.pos, super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                class MyDialogRef {}
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog({
    _i2.Color barrierColor = const _i2.Color(0x80000000),
    required _i3.MyDialogRef pos,
  }) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i4.MyDialog(
                  completer: closeDialog,
                  pos: pos,
                )),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });

    group('with @DialogConfig()', () {
      test(
          'should generate dialog method with custom default barrier color.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/annotations.dart';
                import 'package:fluorflow/fluorflow.dart';

                @DialogConfig(
                  defaultBarrierColor: 0x34ff0000,
                )
                class MyDialog extends FluorFlowSimpleDialog {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x34ff0000)}) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should generate dialog method with custom page builder.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/annotations.dart';
                import 'package:fluorflow/fluorflow.dart';
               
                import 'b.dart';

                @DialogConfig(
                  routeBuilder: RouteBuilder.custom,
                  pageRouteBuilder: CustomBuilder,
                )
                class MyDialog extends FluorFlowSimpleDialog {
                  const MyDialog({super.key, required this.completer});
                }
              ''',
                'a|lib/b.dart': '''
                import 'package:flutter/material.dart';

                class CustomBuilder extends PageRouteBuilder {}
              '''
              },
              outputs: {
                'a|lib/app.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i4;
import 'package:a/b.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i3.CustomBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i4.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));

      test(
          'should throw when custom page is requested, but no page builder is provided.',
          () async {
        try {
          await testBuilder(
              DialogBuilder(BuilderOptions.empty),
              {
                'a|lib/a.dart': '''
                  import 'package:fluorflow/annotations.dart';
                  import 'package:fluorflow/fluorflow.dart';
                  import 'package:flutter/material.dart';

                  @DialogConfig(
                    routeBuilder: RouteBuilder.custom,
                  )
                  class MyDialog extends FluorFlowSimpleDialog {
                    const MyDialog({super.key, required this.completer});
                  }

                  class CustomBuilder extends PageRouteBuilder {}
              '''
              },
              reader: await PackageAssetReader.currentIsolate());
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<InvalidGenerationSourceError>());
        }
      });

      for (final (transition, resultBuilder) in RouteBuilder.values
          .where((t) => t != RouteBuilder.custom)
          .map((t) => (t, '${t.name.pascalCase}PageRouteBuilder'))) {
        test(
            'should use correct page route builder '
            '($resultBuilder) for transition (${transition.name}).',
            () async => await testBuilder(
                DialogBuilder(BuilderOptions.empty),
                {
                  'a|lib/a.dart': '''
                    import 'package:fluorflow/annotations.dart';
                    import 'package:fluorflow/fluorflow.dart';
                    import 'package:flutter/material.dart';

                    @DialogConfig(
                      routeBuilder: RouteBuilder.${transition.name},
                    )
                    class MyDialog extends FluorFlowSimpleDialog {
                      const MyDialog({super.key, required this.completer});
                    }
                  ''',
                },
                outputs: {
                  'a|lib/app.dialogs.dart': '''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.$resultBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.\$1, r?.\$2));
}
''',
                },
                reader: await PackageAssetReader.currentIsolate()));
      }
    });

    group('with Builder Configuration', () {
      test(
          'should use custom output if configured.',
          () async => await testBuilder(
              DialogBuilder(BuilderOptions({
                'output': 'lib/app/my.dialogs.dart',
              })),
              {
                'a|lib/a.dart': '''
                import 'package:fluorflow/fluorflow.dart';

                class MyDialog extends FluorFlowSimpleDialog {
                  const MyDialog({super.key, required this.completer});
                }
              '''
              },
              outputs: {
                'a|lib/app/my.dialogs.dart': r'''
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ui' as _i2;

import 'package:a/a.dart' as _i3;
import 'package:fluorflow/fluorflow.dart' as _i1;

extension Dialogs on _i1.DialogService {
  Future<(bool?, dynamic)> showMyDialog(
          {_i2.Color barrierColor = const _i2.Color(0x80000000)}) =>
      showDialog<(bool?, dynamic)>(
        barrierColor: barrierColor,
        dialogBuilder: _i1.NoTransitionPageRouteBuilder(
            pageBuilder: (
          _,
          __,
          ___,
        ) =>
                _i3.MyDialog(completer: closeDialog)),
      ).then((r) => (r?.$1, r?.$2));
}
'''
              },
              reader: await PackageAssetReader.currentIsolate()));
    });
  });
}
