{...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    yamlFormat = pkgs.formats.yaml {};
  in {
    packages.sops-yaml = yamlFormat.generate ".sops.yaml" {
      keys = {
        "&user-logan" = "age15xagf0337s3w73sps8dfpnup39rglkul8km9hkc8m9daz5yldu4qqr4yfl";
        "&host-nijusan" = "age1nrxg0qkcqfx5s76x3md2jakwd9tslqry0y2k0lp4u4ngjje4z3dq8v3xyq";
      };
      creation_rules = [
        {
          path_regex = "^secrets/[^/]+\.(yaml|json|env|ini|bin)$";
          key_groups = [{age = ["*user-logan"];}];
        }
        {
          path_regex = "^secrets/nijusan/[^/]+\.(yaml|json|env|ini|bin)$";
          key_groups = [
            {age = ["*user-logan"];}
            {age = ["*host-nijusan"];}
          ];
        }
      ];
    };
  };
}
