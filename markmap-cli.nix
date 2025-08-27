{ pkgs }:

pkgs.buildNpmPackage rec {
  pname = "markmap-cli";
  version = "0.17.1";

  src = pkgs.fetchFromGitHub {
    owner = "markmap";
    repo = "markmap";
    rev = "v${version}";
    sha256 = "sha256-qqkaA0sl3Ycz3yjgxlpHIRrSxmYR/mcjCyVWuoggEug=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  postPatch = ''
    npm install --package-lock-only
  '';

  npmBuild = "npm run build";

  meta = with pkgs.lib; {
    description = "Visualize markdown documents as mindmaps";
    homepage = "https://markmap.js.org/";
    license = licenses.mit;
  };
}
