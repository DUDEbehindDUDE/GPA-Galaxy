# About
GPA Galaxy is an app I designed for the 2024 FBLA mobile app development thing. GPA Galaxy is a galactic-themed twist to your high school portfolio—log your grades, and earn achievements based on your academic, extracurricular, and volunteering live, and brag about these on social media. 

# Documentation
All documentation on this project can be found on the wiki tab [here](https://github.com/DUDEbehindDUDE/GPA-Galaxy/wiki).

# Compilation instructions
Only Android is officially supported at this time. If you wish to compile to other platforms, such as iOS, you likely can, but if you come across any bugs, compilation errors, or otherwise any other errors, **you are on your own**. Here are the instructions for compiling the Android version of this app:
1. Install the Flutter SDK by following the instructions [here](https://flutter-ko.dev/get-started/install).
2. Clone or download this repository, and open a terminal/command prompt in the folder that you installed it to.
3. Run the following commands in the terminal:  
`flutter clean`  
`flutter pub get`  
`flutter build apk --release`  
If any of these commands fail, make sure you have properly installed the Flutter SDK as per the official instructions. You may also have to run `flutter doctor` and agree to the terms of flutter and/or configure one or two things it says.
4. You should be able to find the compiled APK in `./build/app/outputs/flutter-apk/`. You can then transfer this APK to your Android device, and open it to install it like any other APK. Because of Google's attempts to prevent side loading apps, it may warn you that this app may be dangerous. If this happens, tap more options, and install anyway.
