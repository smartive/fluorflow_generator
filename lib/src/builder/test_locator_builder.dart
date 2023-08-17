import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:fluorflow/annotations.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

extension on BuilderOptions {
  String get output => config['output'] ?? 'test/test.locator.dart';
}

class TestLocatorBuilder implements Builder {
  static final _allDartFilesInLib = Glob('{lib/*.dart,lib/**/*.dart}');

  final BuilderOptions options;

  const TestLocatorBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final packageConfig = await buildStep.packageConfig;
    if (!packageConfig.packages.any((p) => p.name == 'mockito')) {
      // do not run the builder when mockito is not installed.
      log.info('Mockito is not installed, skipping builder.');
      return;
    }

    final output = AssetId(buildStep.inputId.package, options.output);
    final resolver = buildStep.resolver;
    final locatorRef = refer('locator', 'package:fluorflow/fluorflow.dart');
    final mocksUri = '${p.basenameWithoutExtension(options.output)}.mocks.dart';

    var outputLib = Library((b) => b..ignoreForFile.add('type=lint'));
    var setupTestLocatorMethodBody = Block();
    var setupTestLocatorMethod = Method((b) => b
      ..name = 'setupTestLocator'
      ..returns = refer('void'));

    final mockedTypes = List<Reference>.empty(growable: true);

    final isFactory = TypeChecker.fromRuntime(Factory);
    final nonFactory = TypeChecker.any([
      TypeChecker.fromRuntime(Singleton),
      TypeChecker.fromRuntime(AsyncSingleton),
      TypeChecker.fromRuntime(LazySingleton),
    ]);

    await for (final assetId in buildStep.findAssets(_allDartFilesInLib)) {
      if (!await resolver.isLibrary(assetId)) {
        continue;
      }

      final lib = LibraryReader(await resolver.libraryFor(assetId));

      for (final AnnotatedElement(:annotation, :element)
          in lib.annotatedWith(TypeChecker.any([
        nonFactory,
        isFactory,
      ]))) {
        // For all annotations (except Factory), the mocked element is either
        // the annotated class or the returnvalue of the factory function.
        // For all factories (Factory annotations), the mocked element is the
        // return value regardless of params. But the factory is still registered.
        final originalType = switch (element) {
          final ClassElement e =>
            refer(e.displayName, lib.pathToElement(e).toString()),
          FunctionElement(returnType: final InterfaceType rt)
              when (rt.isDartAsyncFuture || rt.isDartAsyncFutureOr) =>
            refer(
                rt.typeArguments.first.getDisplayString(withNullability: true),
                lib.pathToElement(rt.typeArguments.first.element!).toString()),
          FunctionElement(:final returnType) => refer(
              returnType.getDisplayString(withNullability: true),
              lib.pathToElement(returnType.element!).toString()),
          _ => throw InvalidGenerationSourceError('Invalid element type.',
              element: element),
        };
        final mockType = refer('Mock${originalType.symbol}', mocksUri);
        mockedTypes.add(originalType);

        if (annotation.instanceOf(nonFactory)) {
          outputLib = outputLib.rebuild((b) => b.body.add(Method((b) => b
            ..name = 'get${mockType.symbol}'
            ..returns = mockType
            ..body = Block.of([
              Code.scope((a) =>
                  'if (${a(locatorRef)}.isRegistered<${a(originalType)}>())'
                  '{${a(locatorRef)}.unregister<${a(originalType)}>();}'),
              declareFinal('service')
                  .assign(mockType.newInstance([]))
                  .statement,
              locatorRef
                  .property('registerSingleton')
                  .call([refer('service')], {}, [originalType]).statement,
              refer('service').returned.statement,
            ]))));
        } else {
          outputLib = outputLib.rebuild((b) => b.body.add(Method((b) => b
            ..name = 'get${mockType.symbol}'
            ..returns = mockType
            ..body = Block.of([
              Code.scope((a) =>
                  'if (${a(locatorRef)}.isRegistered<${a(originalType)}>())'
                  '{${a(locatorRef)}.unregister<${a(originalType)}>();}'),
              declareFinal('service')
                  .assign(mockType.newInstance([]))
                  .statement,
              locatorRef.property('registerFactory').call(
                  [Method((b) => b.body = refer('service').code).closure],
                  {},
                  [originalType]).statement,
              refer('service').returned.statement,
            ]))));
        }

        setupTestLocatorMethodBody = setupTestLocatorMethodBody.rebuild(
            (b) => b.addExpression(refer('get${mockType.symbol}').call([])));
      }
    }

    setupTestLocatorMethod = setupTestLocatorMethod.rebuild((b) => b
      ..body = setupTestLocatorMethodBody
      ..annotations.add(
          refer('GenerateNiceMocks', 'package:mockito/annotations.dart').call([
        literalList(mockedTypes.map((t) =>
            refer('MockSpec', 'package:mockito/annotations.dart')
                .newInstance([], {
              'onMissingStub':
                  refer('OnMissingStub', 'package:mockito/annotations.dart')
                      .property('returnDefault')
            }, [
              t
            ])))
      ])));
    outputLib = outputLib.rebuild((b) => b
      ..body.add(setupTestLocatorMethod)
      ..body.add(Method((b) => b
        ..name = 'tearDownLocator'
        ..returns = refer('void')
        ..lambda = true
        ..body = locatorRef.property('reset').call([]).code)));

    buildStep.writeAsString(
        output,
        DartFormatter().format(outputLib
            .accept(DartEmitter.scoped(
                useNullSafetySyntax: true, orderDirectives: true))
            .toString()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'lib/$lib$': [options.output],
      };
}
