import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// ويدجت التحميل
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.color,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// ويدجت تحميل صغير للأزرار
class SmallLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const SmallLoadingWidget({
    Key? key,
    this.color,
    this.size = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.textOnPrimaryColor,
        ),
      ),
    );
  }
}

/// ويدجت تحميل مع خلفية
class OverlayLoadingWidget extends StatelessWidget {
  final String? message;
  final bool isVisible;

  const OverlayLoadingWidget({
    Key? key,
    this.message,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: AppColors.shadowColor,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LoadingWidget(message: message),
          ),
        ),
      ),
    );
  }
}
