String macBytesToString(List<int> macBytes) {
  return macBytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join(':');
}
