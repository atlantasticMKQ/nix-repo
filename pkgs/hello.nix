{ stdenv, writeShellScriptBin }:

stdenv.mkDerivation {
  pname = "hello";
  version = "0.1.0";
  dontUnpack = true;

  installPhase = ''
mkdir -p $out/bin
cat > $out/bin/hello <<'SH'
#!/usr/bin/env bash
echo "Hello from my flake!"
SH
chmod +x $out/bin/hello
'';

  meta.description = "Tiny hello app for flake demo";
}
