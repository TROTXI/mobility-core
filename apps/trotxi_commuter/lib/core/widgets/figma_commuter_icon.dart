import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Original Figma vectors at their exported dimensions. Rectangle portions
/// of dock icons use the native geometry specified by the same component.
enum CommuterIcon {
  home,
  trips,
  wallet,
  profile,
  search,
  info,
  sun,
  moon,
  boardingCode,
}

class FigmaCommuterIcon extends StatelessWidget {
  const FigmaCommuterIcon(this.icon, {super.key, this.color, this.cutout});
  final CommuterIcon icon;
  final Color? color;
  final Color? cutout;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = color ?? Theme.of(context).colorScheme.onSurface;
    Widget asset(String name, {bool tint = true}) => SvgPicture.asset(
      'assets/figma/$name.svg',
      colorFilter: tint ? ColorFilter.mode(ink, BlendMode.srcIn) : null,
    );
    Widget box(double width, double height, {bool filled = false}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: filled ? ink : null,
        border: filled ? null : Border.all(color: ink, width: 1.5),
        borderRadius: BorderRadius.circular(filled ? 2 : 3),
      ),
    );
    return ExcludeSemantics(
      child: SizedBox(
        width: 24,
        height: 24,
        child: switch (icon) {
          CommuterIcon.boardingCode => asset('boarding-code'),
          CommuterIcon.search => asset('search-${dark ? 'dark' : 'light'}'),
          CommuterIcon.info => asset('info-${dark ? 'dark' : 'light'}'),
          CommuterIcon.sun => Center(child: asset('sun', tint: false)),
          CommuterIcon.moon => Center(child: asset('moon', tint: false)),
          CommuterIcon.home => Stack(
            children: [
              Positioned(top: 1, left: 2.47, child: asset('home-roof')),
              Positioned(top: 9, left: 3.5, child: box(17, 12, filled: true)),
              Positioned(
                top: 14,
                left: 9.5,
                child: Container(
                  width: 5,
                  height: 7,
                  decoration: BoxDecoration(
                    color: cutout ?? Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
          CommuterIcon.trips => Stack(
            children: [
              Positioned(top: 2, left: 3, child: box(18, 20)),
              Positioned(top: 10, left: 7, child: asset('trips-line')),
            ],
          ),
          CommuterIcon.wallet => Stack(
            children: [
              Positioned(top: 4.5, left: 2, child: box(20, 15)),
              Positioned(top: 10.5, left: 16, child: asset('wallet-dot')),
            ],
          ),
          CommuterIcon.profile => Stack(
            children: [
              Positioned(top: 1, left: 8, child: asset('profile-head')),
              Positioned(top: 11, left: 2, child: asset('profile-body')),
            ],
          ),
        },
      ),
    );
  }
}
