{ stdenv, buildPythonPackage, fetchPypi
, bottle, click, colorama
, lockfile, pyserial, requests
, semantic-version
, git
}:

buildPythonPackage rec {
  pname = "platformio";
  version = "3.5.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "21809f0d7e7ab368946dc3b939bca03992bfe3bfeaa759d53107a61b60179ad0";
  };

  propagatedBuildInputs =  [
    bottle click colorama git lockfile
    pyserial requests semantic-version
  ];

  patches = [ ./fix-searchpath.patch ];

  meta = with stdenv.lib; {
    description = "An open source ecosystem for IoT development";
    homepage = http://platformio.org;
    maintainers = with maintainers; [ mog makefu ];
    license = licenses.asl20;
  };
}
