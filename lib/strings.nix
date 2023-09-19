{ lib }: {
  substitute = dict:
    lib.replaceStrings (lib.attrNames dict)
    (map toString (lib.attrValues dict));

  ensurePrefix = prefix: content:
    if lib.hasPrefix prefix content then content else "${content}${prefix}";

  ensureSuffix = suffix: content:
    if lib.hasSuffix suffix content then content else "${content}${suffix}";
}
