{ pkgs }:

pkgs.buildNpmPackage rec {
  pname = "markmap-cli";
  version = "0.17.1";

  src = pkgs.fetchFromGitHub {
    owner = "markmap";
    repo = "markmap";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  npmBuild = "npm run build";

  meta = with pkgs.lib; {
    description = "Visualize markdown documents as mindmaps";
    homepage = "https://markmap.js.org/";
    license = licenses.mit;
  };
}
