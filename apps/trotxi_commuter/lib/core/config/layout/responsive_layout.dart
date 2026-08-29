import 'package:flutter/material.dart';

enum AppDeviceClass { phone, tabletPortrait, tabletLandscape }

abstract final class AppBreakpoints {
  static const double tabletShortestSide = 600;
}

abstract final class AppReferenceDevices {
  static const Size phone = Size(390, 844);
  static const Size tabletPortrait = Size(834, 1112);
  static const Size tabletLandscape = Size(1194, 834);
}

@immutable
class ResponsiveLayoutInfo {
  const ResponsiveLayoutInfo({required this.size, required this.deviceClass});

  factory ResponsiveLayoutInfo.fromSize(Size size) {
    return ResponsiveLayoutInfo(size: size, deviceClass: classify(size));
  }

  factory ResponsiveLayoutInfo.of(BuildContext context) {
    return ResponsiveLayoutInfo.fromSize(MediaQuery.sizeOf(context));
  }

  final Size size;
  final AppDeviceClass deviceClass;

  bool get isPhone => deviceClass == AppDeviceClass.phone;
  bool get isTablet => !isPhone;
  bool get isTabletPortrait => deviceClass == AppDeviceClass.tabletPortrait;
  bool get isTabletLandscape => deviceClass == AppDeviceClass.tabletLandscape;

  Orientation get orientation =>
      size.width > size.height ? Orientation.landscape : Orientation.portrait;

  T select<T>({
    required T phone,
    required T tabletPortrait,
    required T tabletLandscape,
  }) {
    return switch (deviceClass) {
      AppDeviceClass.phone => phone,
      AppDeviceClass.tabletPortrait => tabletPortrait,
      AppDeviceClass.tabletLandscape => tabletLandscape,
    };
  }

  static AppDeviceClass classify(Size size) {
    if (size.shortestSide < AppBreakpoints.tabletShortestSide) {
      return AppDeviceClass.phone;
    }
    return size.width > size.height
        ? AppDeviceClass.tabletLandscape
        : AppDeviceClass.tabletPortrait;
  }
}
