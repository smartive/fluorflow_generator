import 'package:build/build.dart';

import 'src/builder/locator_builder.dart';
import 'src/builder/router_builder.dart';

Builder locatorBuilder(BuilderOptions options) => LocatorBuilder(options);

Builder routerBuilder(BuilderOptions options) => RouterBuilder(options);
