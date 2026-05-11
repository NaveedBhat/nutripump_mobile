import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/app_typography.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text('Verify Email',
                style: AppTypography.h3(context)
                    .copyWith(fontSize: R.sp(context, 18)))),
        body: Center(
            child: Text('Verify Email — Coming in Sprint 2',
                style: AppTypography.bodySM(context)
                    .copyWith(fontSize: R.sp(context, 14)))),
      );
}
