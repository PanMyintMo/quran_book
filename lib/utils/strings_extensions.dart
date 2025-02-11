extension StringsExtensions on String {
  String addS(int count) {
    if (count <= 0) {
      return this;
    }
    return "${this}s";
  }
}
