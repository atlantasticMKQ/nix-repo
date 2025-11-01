{
  description = "My first flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems
          (system: f (import nixpkgs { inherit system; }));
    in
      {
        # 构建“包集合”
        packages = forAllSystems (pkgs: {
          hello = pkgs.callPackage ./pkgs/hello.nix {};
          # 让 `.#` 指向 hello
          default = self.packages.${pkgs.system}.hello;  
        });

        # 定义可运行应用：`nix run .#hello`
        apps = forAllSystems (pkgs: {
          hello = {
            type = "app";
            program = "${self.packages.${pkgs.system}.hello}/bin/hello";
          };
          default = self.apps.${pkgs.system}.hello;
        });

        # 开发环境：`nix develop` 进入；`devShells` 可装工具链等
        devShells = forAllSystems (pkgs: {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git curl nixpkgs-fmt ];
          };
        });

        # 代码格式化器：`nix fmt`
        formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

        # CI/本地检查：`nix flake check` 会构建这些目标
        checks = forAllSystems (pkgs: {
          build-hello = self.packages.${pkgs.system}.hello;
        });
      };
}
