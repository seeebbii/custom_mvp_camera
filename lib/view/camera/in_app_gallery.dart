import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:mvp_camera/app/utils/colors.dart';
import 'package:exif/exif.dart';
class InAppGallery extends StatefulWidget {
  const InAppGallery({Key? key}) : super(key: key);

  @override
  State<InAppGallery> createState() => _InAppGalleryState();
}

class _InAppGalleryState extends State<InAppGallery> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Gallery',
            style: Theme.of(context).textTheme.headline2?.copyWith(
                color: primaryColor,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () {
            navigationController.goBack();
          },
          icon: Icon(
            Icons.chevron_left,
            color: primaryColor,
            size: 25.sp,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0.r),
        child: Obx(() => GridView.builder(
            itemCount: myCameraController.listOfCapturedImages.length,
            addAutomaticKeepAlives: true,
            cacheExtent: 999,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                crossAxisSpacing: 3.sp,
                mainAxisSpacing: 3.sp),
            itemBuilder: (_, index) {
              printExifOf();
              return ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Image.file(
                    myCameraController.listOfCapturedImages[index],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ));
            })),
      ),
    );
  }
  printExifOf() async {

  final fileBytes = myCameraController.listOfCapturedImages[0].readAsBytesSync();
  final data = await readExifFromBytes(fileBytes);

  if (data.isEmpty) {
    print("No EXIF information found");
    return;
  }

  if (data.containsKey('JPEGThumbnail')) {
    print('File has JPEG thumbnail');
    data.remove('JPEGThumbnail');
  }
  if (data.containsKey('TIFFThumbnail')) {
    print('File has TIFF thumbnail');
    data.remove('TIFFThumbnail');
  }

  for (final entry in data.entries) {
    print("${entry.key}: ${entry.value}");
  }
  
}

}
