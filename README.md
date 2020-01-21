# Melt Clock

This is a clockface for the Lenovo Smart Clock using Flutter and Dart, written for the Flutter Clock challenge.

## Features

Realtime backgound animation, available in two flavors according to the device theme. Also tinted depending on the weathers conditions.

Displays time in digital format through sliced shapes, and weather forecast in upper right corner.

<img src='Screenshot_20200120-163121.png' width='800'>

<img src='Screenshot_20200120-163204.png' width='800'>

## Trivia

I entered the project ten days before the dead line, with the status of " Never wrote a line of Dart or Flutter" before. Until there i had only tested the demo app.

The result is very close from the clockface i had planned to do at start.
Thanks to documentation and the Flutter youtube channel that has a bunch of ressources to make some quick decisions on widgets use cases)

Otherwise there's a warning at compilation i couldn't fix.
Many variables are defined dynamically to the device size, it could happen that numbers position in shapes is not at best in some case.