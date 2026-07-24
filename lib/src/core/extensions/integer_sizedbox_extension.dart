import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension on [num] to quickly create horizontal and vertical SizedBoxes using ScreenUtil.
extension IntegerSizedBoxExtension on num {
  SizedBox get hS => SizedBox(height: h);
  SizedBox get wS => SizedBox(width: h);
}
