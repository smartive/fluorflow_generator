import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:fluorflow/annotations.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

extension on BuilderOptions {
  String get output => config['output'] ?? 'lib/app.locator.dart';

  bool get emitAllReady => config['emitAllReady'] ?? true;

  Map<String, dynamic> get registerServices =>
      config['register_services'] ?? {};

  bool get registerNavigationService => registerServices['navigation'] ?? true;
}

class LocatorBuilder implements Builder {
  static final _allDartFilesInLib = Glob('{lib/*.dart,lib/**/*.dart}');

  final BuilderOptions options;

  const LocatorBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final output = AssetId(buildStep.inputId.package, options.output);
    final resolver = buildStep.resolver;

    final locatorRef = refer('locator', 'package:fluorflow/fluorflow.dart');

    var setupLocatorBlock = Block();
    var factoryExtension = Extension((b) => b
      ..name = 'Factories'
      ..on = refer('Locator', 'package:fluorflow/fluorflow.dart'));

    await for (final assetId in buildStep.findAssets(_allDartFilesInLib)) {
      if (!await resolver.isLibrary(assetId)) {
        continue;
      }

      final lib = LibraryReader(await resolver.libraryFor(assetId));

      setupLocatorBlock =
          _handleClassSingletons(assetId, lib, locatorRef, setupLocatorBlock);
      setupLocatorBlock = _handleFunctionSingletons(
          assetId, lib, locatorRef, setupLocatorBlock);
      setupLocatorBlock = _handleClassLazySingletons(
          assetId, lib, locatorRef, setupLocatorBlock);
      setupLocatorBlock = _handleFunctionLazySingletons(
          assetId, lib, locatorRef, setupLocatorBlock);
      setupLocatorBlock = _handleClassAsyncSingletons(
          assetId, lib, locatorRef, setupLocatorBlock);
      setupLocatorBlock = _handleFunctionAsyncSingletons(
          assetId, lib, locatorRef, setupLocatorBlock);
      (setupLocatorBlock, factoryExtension) = _handleClassFactories(
          assetId, lib, locatorRef, setupLocatorBlock, factoryExtension);
    }

    if (options.registerNavigationService) {
      setupLocatorBlock = setupLocatorBlock.rebuild((b) => b
        ..addExpression(locatorRef.property('registerLazySingleton').call([
          Method((b) => b
            ..body =
                refer('NavigationService', 'package:fluorflow/fluorflow.dart')
                    .newInstance([]).code).closure,
        ])));
    }

    if (setupLocatorBlock.statements.isEmpty) {
      return;
    }

    if (options.emitAllReady) {
      setupLocatorBlock = setupLocatorBlock.rebuild((b) =>
          b.addExpression(locatorRef.property('allReady').call([]).awaited));
    }

    var outputLib = Library((b) => b
      ..ignoreForFile.add('type=lint')
      ..body.add(Method((b) => b
        ..name = 'setupLocator'
        ..modifier = MethodModifier.async
        ..body = setupLocatorBlock
        ..returns = refer('Future<void>'))));

    if (factoryExtension.methods.isNotEmpty) {
      outputLib = outputLib.rebuild((b) => b..body.add(factoryExtension));
    }

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

  Block _handleClassSingletons(AssetId assetId, LibraryReader lib,
      Reference locatorRef, Block setupLocatorBlock) {
    var block = setupLocatorBlock;

    for (final AnnotatedElement(:annotation, element: Element(:displayName))
        in lib
            .annotatedWith(TypeChecker.fromRuntime(Singleton))
            .where((element) => element.element is ClassElement)) {
      if (annotation.read('dependencies').isNull) {
        block = block.rebuild((b) => b
          ..addExpression(locatorRef.property('registerSingleton').call([
            refer(displayName, assetId.uri.toString()).newInstance([]),
          ])));
      } else {
        final deps = annotation.read('dependencies').listValue;

        block = block.rebuild((b) => b
          ..addExpression(
              locatorRef.property('registerSingletonWithDependencies').call([
            Method((b) => b
              ..body = refer(displayName, assetId.uri.toString())
                  .newInstance([]).code).closure,
          ], {
            'dependsOn': literalList(deps
                .map((d) => d.toTypeValue()?.element)
                .nonNulls
                .map((d) =>
                    refer(d.displayName, lib.pathToElement(d).toString())))
          })));
      }
    }

    return block;
  }

  Block _handleFunctionSingletons(AssetId assetId, LibraryReader lib,
      Reference locatorRef, Block setupLocatorBlock) {
    var block = setupLocatorBlock;

    for (final AnnotatedElement(:annotation, element: Element(:displayName))
        in lib
            .annotatedWith(TypeChecker.fromRuntime(Singleton))
            .where((element) => element.element is FunctionElement)) {
      if (annotation.read('dependencies').isNull) {
        block = block.rebuild((b) => b
          ..addExpression(locatorRef.property('registerSingleton').call([
            refer(displayName, assetId.uri.toString()).call([]),
          ])));
      } else {
        final deps = annotation.read('dependencies').listValue;

        block = block.rebuild((b) => b
          ..addExpression(
              locatorRef.property('registerSingletonWithDependencies').call([
            Method((b) => b
                  ..body =
                      refer(displayName, assetId.uri.toString()).call([]).code)
                .closure,
          ], {
            'dependsOn': literalList(deps
                .map((d) => d.toTypeValue()?.element)
                .nonNulls
                .map((d) =>
                    refer(d.displayName, lib.pathToElement(d).toString())))
          })));
      }
    }

    return block;
  }

  Block _handleClassLazySingletons(AssetId assetId, LibraryReader lib,
      Reference locatorRef, Block setupLocatorBlock) {
    var block = setupLocatorBlock;

    for (final AnnotatedElement(element: Element(:displayName)) in lib
        .annotatedWith(TypeChecker.fromRuntime(LazySingleton))
        .where((element) => element.element is ClassElement)) {
      block = block.rebuild((b) => b
        ..addExpression(locatorRef.property('registerLazySingleton').call([
          Method((b) => b
            ..body = refer(displayName, assetId.uri.toString())
                .newInstance([]).code).closure,
        ])));
    }

    return block;
  }

  Block _handleFunctionLazySingletons(AssetId assetId, LibraryReader lib,
      Reference locatorRef, Block setupLocatorBlock) {
    var block = setupLocatorBlock;

    for (final AnnotatedElement(element: Element(:displayName)) in lib
        .annotatedWith(TypeChecker.fromRuntime(LazySingleton))
        .where((element) => element.element is FunctionElement)) {
      block = block.rebuild((b) => b
        ..addExpression(locatorRef
            .property('registerLazySingleton')
            .call([refer(displayName, assetId.uri.toString())])));
    }

    return block;
  }

  Block _handleClassAsyncSingletons(AssetId assetId, LibraryReader lib,
      Reference locatorRef, Block setupLocatorBlock) {
    var block = setupLocatorBlock;

    for (final AnnotatedElement(:annotation, :element) in lib
        .annotatedWith(TypeChecker.fromRuntime(AsyncSingleton))
        .where((element) => element.element is ClassElement)) {
      if (annotation.read('factory').isNull) {
        throw InvalidGenerationSourceError(
            'AsyncSingleton must have a factory method if used on a class',
            element: element);
      }

      final factory = annotation.read('factory').objectValue.toFunctionValue();

      var named = <String, Expression>{};

      if (!annotation.read('dependencies').isNull) {
        final deps = annotation.read('dependencies').listValue;

        named = {
          'dependsOn': literalList(deps
              .map((d) => d.toTypeValue()?.element)
              .nonNulls
              .map(
                  (d) => refer(d.displayName, lib.pathToElement(d).toString())))
        };
      }

      if (factory
          case MethodElement(
            displayName: final methodName,
            enclosingElement: ClassElement(displayName: final className)
          )) {
        block = block.rebuild((b) => b
          ..addExpression(locatorRef.property('registerSingletonAsync').call([
            refer(className, assetId.uri.toString()).property(methodName),
          ], named)));
      } else if (factory case FunctionElement(:final displayName)) {
        block = block.rebuild((b) => b
          ..addExpression(locatorRef.property('registerSingletonAsync').call([
            refer(displayName, assetId.uri.toString()),
          ], named)));
      }
    }

    return block;
  }

  Block _handleFunctionAsyncSingletons(AssetId assetId, LibraryReader lib,
      Reference locatorRef, Block setupLocatorBlock) {
    var block = setupLocatorBlock;

    for (final AnnotatedElement(:annotation, :element) in lib
        .annotatedWith(TypeChecker.fromRuntime(AsyncSingleton))
        .where((element) => element.element is FunctionElement)) {
      final factory = element as FunctionElement;

      var named = <String, Expression>{};

      if (!annotation.read('dependencies').isNull) {
        final deps = annotation.read('dependencies').listValue;

        named = {
          'dependsOn': literalList(deps
              .map((d) => d.toTypeValue()?.element)
              .nonNulls
              .map(
                  (d) => refer(d.displayName, lib.pathToElement(d).toString())))
        };
      }

      block = block.rebuild((b) => b
        ..addExpression(locatorRef.property('registerSingletonAsync').call([
          refer(factory.displayName, assetId.uri.toString()),
        ], named)));
    }

    return block;
  }

  (Block, Extension) _handleClassFactories(
      AssetId assetId,
      LibraryReader lib,
      Reference locatorRef,
      Block setupLocatorBlock,
      Extension locatorExtension) {
    var block = setupLocatorBlock;
    var factoryExtension = locatorExtension;

    for (final AnnotatedElement(:element) in lib
        .annotatedWith(TypeChecker.fromRuntime(Factory))
        .where((element) => element.element is FunctionElement)) {
      final func = element as FunctionElement;

      if (func.isPrivate) {
        throw InvalidGenerationSourceError('Factories cannot be private.',
            element: element);
      }

      if (func.parameters.isEmpty) {
        // when there are no params, we just register the factory.
        block = block.rebuild((b) => b
          ..addExpression(locatorRef.property('registerFactory').call([
            Method((b) => b
              ..body = refer(element.displayName, assetId.uri.toString())
                  .call([]).code).closure,
          ])));
      } else if (func.parameters.length > 2) {
        throw InvalidGenerationSourceError(
            'Factories can only have 0, 1 or 2 parameters.',
            element: element);
      } else {
        // when there are params, we register the factory with the params.
        block = block.rebuild((b) => b
          ..addExpression(locatorRef.property('registerFactoryParam').call(
            [
              Method((b) => b
                ..requiredParameters.add(Parameter((b) => b..name = 'p1'))
                ..requiredParameters.add(Parameter(
                    (b) => b..name = func.parameters.length == 1 ? '_' : 'p2'))
                ..body =
                    refer(element.displayName, assetId.uri.toString()).call([
                  if (func.parameters.isNotEmpty) refer('p1'),
                  if (func.parameters.length == 2) refer('p2'),
                ]).code).closure,
            ],
            {},
            [
              refer(func.returnType.toString(), assetId.uri.toString()),
              if (func.parameters.isNotEmpty)
                refer(
                    func.parameters.first.type.element!.displayName,
                    lib
                        .pathToElement(func.parameters.first.type.element!)
                        .toString()),
              if (func.parameters.length == 1) refer('void'),
              if (func.parameters.length == 2)
                refer(
                    func.parameters[1].type.element!.displayName,
                    lib
                        .pathToElement(func.parameters[1].type.element!)
                        .toString()),
            ],
          )));

        // add the factory to the Locator extension for convenience
        var ext = Method((b) => b
          ..name = 'get${func.returnType.toString()}'
          ..returns = refer(func.returnType.toString(), assetId.uri.toString())
          ..body = refer('get').call([], {
            'param1': refer(func.parameters.first.displayName),
            ...func.parameters.length == 2
                ? {'param2': refer(func.parameters[1].displayName)}
                : {}
          }).code
          ..requiredParameters.add(Parameter((b) => b
            ..name = func.parameters.first.displayName
            ..type = refer(
                func.parameters.first.type.element!.displayName,
                lib
                    .pathToElement(func.parameters.first.type.element!)
                    .toString()))));
        if (func.parameters.length == 2) {
          ext = ext.rebuild((b) => b
            ..requiredParameters.add(Parameter((b) => b
              ..name = func.parameters[1].displayName
              ..type = refer(
                  func.parameters[1].type.element!.displayName,
                  lib
                      .pathToElement(func.parameters[1].type.element!)
                      .toString()))));
        }

        factoryExtension = factoryExtension.rebuild((b) => b..methods.add(ext));
      }
    }

    return (block, factoryExtension);
  }
}
