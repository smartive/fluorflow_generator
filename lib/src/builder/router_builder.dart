import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:fluorflow/annotations.dart';
import 'package:glob/glob.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

extension on BuilderOptions {
  String get output => config['output'] ?? 'lib/app.router.dart';
}

class RouterBuilder implements Builder {
  static final _allDartFilesInLib = Glob('{lib/*.dart,lib/**/*.dart}');

  final BuilderOptions options;

  const RouterBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final output = AssetId(buildStep.inputId.package, options.output);
    final resolver = buildStep.resolver;

    var routeEnum = Enum((b) => b
      ..name = 'AppRoute'
      ..fields.add(Field((b) => b
        ..modifier = FieldModifier.final$
        ..name = 'path'
        ..type = refer('String')))
      ..constructors.add(Constructor((b) => b
        ..constant = true
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'path'
          ..toThis = true)))));

    final pages = <String, Method>{};

    final routeArgs = <Class>[];

    var navExtension = Extension((b) => b
      ..name = 'RouteNavigation'
      ..on = refer('NavigationService', 'package:fluorflow/services.dart'));

    await for (final assetId in buildStep.findAssets(_allDartFilesInLib)) {
      if (!await resolver.isLibrary(assetId)) {
        continue;
      }

      final lib = LibraryReader(await resolver.libraryFor(assetId));

      for (final AnnotatedElement(:annotation, :element) in lib
          .annotatedWith(TypeChecker.fromRuntime(Routable))
          .where((element) => element.element is ClassElement)) {
        final path = annotation.read('path').isNull
            ? '/${element.displayName.paramCase}'
            : annotation.read('path').stringValue;

        // Add the route to the enum.
        routeEnum = routeEnum.rebuild((b) => b
          ..values.add(EnumValue((b) => b
            ..name = element.displayName.camelCase
            ..arguments.add(literalString(path)))));

        final ctor = element.children.cast<Element?>().firstWhere(
            (element) => element is ConstructorElement,
            orElse: () => null) as ConstructorElement?;

        final params = ctor?.parameters
                .where((p) => p.displayName != 'key')
                .toList(growable: false) ??
            [];

        if (params.isNotEmpty) {
          // There are non "key" parameters, we need to generate route arguments.
          routeArgs.add(Class((b) => b
            ..name = '${element.displayName.pascalCase}Arguments'
            ..fields.addAll(params.map((p) => Field((b) => b
              ..name = p.displayName
              ..modifier = FieldModifier.final$
              ..type = refer(p.type.getDisplayString(withNullability: true),
                  lib.pathToElement(p.type.element!).toString()))))
            ..constructors.add(Constructor((b) => b
              ..constant = true
              ..optionalParameters.addAll(params.map((p) => Parameter((b) => b
                ..name = p.name
                ..toThis = true
                ..required = p.isRequired
                ..defaultTo =
                    p.hasDefaultValue ? Code(p.defaultValueCode!) : null
                ..named = p.isNamed)))))));
        }

        // Create the navigation to extension.
        if (annotation.read('navigateToExtension').boolValue) {
          navExtension = _addExtension(navExtension, lib,
              prefix: 'navigateTo',
              displayName: element.displayName,
              params: params);
        }

        if (annotation.read('replaceWithExtension').boolValue) {
          navExtension = _addExtension(navExtension, lib,
              prefix: 'replaceWith',
              displayName: element.displayName,
              params: params);
        }

        if (annotation.read('rootToExtension').boolValue) {
          navExtension = _addExtension(navExtension, lib,
              prefix: 'rootTo',
              displayName: element.displayName,
              params: params,
              withPreventDuplicates: false);
        }

        // Add the route object to the pages map.
        pages[path] = Method((b) => b
          ..requiredParameters.add(Parameter((b) => b.name = 'data'))
          ..body = refer('PageRouteBuilder', 'package:flutter/widgets.dart')
              .newInstance([], {
            'settings': refer('data'),
            'pageBuilder': Method((b) => b
              ..requiredParameters.add(Parameter((b) => b.name = '_'))
              ..requiredParameters.add(Parameter((b) => b.name = '__'))
              ..requiredParameters.add(Parameter((b) => b.name = '___'))
              ..lambda = params.isEmpty
              ..body = params.isEmpty
                  ? refer(element.displayName, assetId.uri.toString())
                      .constInstance([]).code
                  : Block.of([
                      declareFinal('args')
                          .assign(refer('data')
                              .property('arguments')
                              .asA(refer('${element.displayName}Arguments')))
                          .statement,
                      refer(element.displayName, assetId.uri.toString())
                          .newInstance(
                              params
                                  .where((p) => p.isPositional)
                                  .map((p) => refer('args').property(p.name)),
                              {
                                for (final p in params.where((p) => p.isNamed))
                                  p.name: refer('args').property(p.name)
                              })
                          .returned
                          .statement
                    ])).closure,
          }).code
          ..lambda = true);
      }
    }

    if (routeEnum.fields.isEmpty) {
      return;
    }

    var outputLib = Library((b) => b
      ..ignoreForFile.add('type=lint')
      ..body.add(routeEnum)
      ..body.add(declareFinal('_pages')
          .assign(literalMap(pages, refer('String'),
              refer('RouteFactory', 'package:flutter/widgets.dart')))
          .statement)
      ..body.addAll(routeArgs)
      ..body.add(Method((b) => b
        ..name = 'onGenerateRoute'
        ..returns = refer('Route?', 'package:flutter/widgets.dart')
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'settings'
          ..type = refer('RouteSettings', 'package:flutter/widgets.dart')))
        ..body = refer('_pages')
            .index(refer('settings').property('name'))
            .nullSafeProperty('call')
            .call([refer('settings')]).code
        ..lambda = true))
      ..body.add(navExtension));

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

  Extension _addExtension(Extension ext, LibraryReader lib,
          {required String prefix,
          required String displayName,
          required Iterable<ParameterElement> params,
          bool withPreventDuplicates = true}) =>
      ext.rebuild((b) => b
        ..methods.add(Method((b) => b
          ..name = '$prefix${displayName.pascalCase}'
          ..returns = refer('Future<T?>?')
          ..types.add(refer('T'))
          ..optionalParameters.addAll(params.map((p) => Parameter((b) => b
            ..name = p.name
            ..type = refer(p.type.getDisplayString(withNullability: true),
                lib.pathToElement(p.type.element!).toString())
            ..required = p.isRequired
            ..defaultTo = p.hasDefaultValue ? Code(p.defaultValueCode!) : null
            ..named = p.isNamed)))
          ..optionalParameters.addAll([
            Parameter((b) => b
              ..name = 'id'
              ..type = refer('int?')
              ..named = true),
            if (withPreventDuplicates)
              Parameter((b) => b
                ..name = 'preventDuplicates'
                ..type = refer('bool')
                ..named = true
                ..defaultTo = literalTrue.code),
          ])
          ..body = refer(prefix).call([
            refer('AppRoute.${displayName.camelCase}.path'),
          ], {
            'id': refer('id'),
            ...withPreventDuplicates
                ? {
                    'preventDuplicates': refer('preventDuplicates'),
                  }
                : {},
            ...params.isNotEmpty
                ? {
                    'arguments': refer('${displayName.pascalCase}Arguments')
                        .newInstance([],
                            {for (final p in params) p.name: refer(p.name)}),
                  }
                : {},
          }).code)));
}
