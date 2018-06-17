{ stdenv, fetchFromGitHub, makeWrapper, cmake
, curl, boost, gdal, glew, soil
, libX11, libXi, libXcursor, libXrandr, libXinerama }:

stdenv.mkDerivation rec {
  version = "0.11.1";
  name    = "openspace-${version}";
  
  src = fetchFromGitHub {
    owner  = "OpenSpace";
    repo   = "OpenSpace";
    rev    = "a65eea61a1b8807ce3d69e9925e75f8e3dfb085d";
    sha256 = "0msqixf30r0d41xmfmzkdfw6w9jkx2ph5clq8xiwrg1jc3z9q7nv";
    fetchSubmodules = true;
  };
  
  buildInputs = [
    makeWrapper cmake
    curl boost gdal glew soil
    libX11 libXi libXcursor libXrandr libXinerama
  ];

  patches = [
    ./vrpn.patch   # see <https://github.com/opensgct/sgct/issues/13>
    ./glm.patch    # see <https://github.com/g-truc/glm/issues/726>
    
    ./constexpr.patch
    ./config.patch
    
    ./assets.patch # WARNING: This patch disables some torrents in a
                   # very dirty way.
  ];

  bundle = "$out/usr/share/openspace";
  
  preConfigure = ''
    cmakeFlagsArray=(
      $cmakeFlagsArray
      "-DCMAKE_BUILD_TYPE="
      "-DCMAKE_INSTALL_PREFIX=${bundle}"
    )
  '';
  
  preInstall = ''
    mkdir -p $out/bin
    mkdir -p ${bundle}
  '';
  
  postInstall = ''
    cp ext/spice/libSpice.so       ${bundle}/lib
    cp ext/ghoul/ext/lua/libLua.so ${bundle}/lib
  '';
  
  postFixup = ''
    for bin in ${bundle}/bin/*
    do
      rpath=$(patchelf --print-rpath $bin)
      patchelf --set-rpath $rpath:${bundle}/lib $bin
      
      name=$(basename $bin)
      makeWrapper $bin $out/bin/$name --run "cd ${bundle}"
    done
  '';
  
  meta = {
    description     = "Open-source astrovisualization project";
    longDescription = ''
      OpenSpace is open source interactive data visualization software
      designed to visualize the entire known universe and portray our
      ongoing efforts to investigate the cosmos.

      WARNING: This build is not very usable for now.
    '';
    homepage  = https://www.openspaceproject.com/;
    license   = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
  };
}
