import subprocess
import yaml
import argparse
import sys

class HelmChart:
    """Class to sync local Chart.yaml with a remote Helm OCI registry."""

    def __init__(self, oci_chart_file: str, oci_path: str, devel: bool = False):
        self.oci_chart_file = oci_chart_file
        self.oci_path = oci_path
        self.devel = devel
        self.local_data = self._read_yaml(self.oci_chart_file)

    def _read_yaml(self, file_path):
        try:
            with open(file_path, 'r') as f:
                return yaml.safe_load(f) or {}
        except FileNotFoundError:
            print(f"Error: File {file_path} not found.")
            sys.exit(1)

    def get_remote_oci_metadata(self):
        """Fetch metadata from the OCI registry using helm show chart."""

        cmd = ["helm", "show", "chart"]
        if self.devel:
            cmd.append("--devel")
        cmd.append(self.oci_path)

        try:
            result = subprocess.run(
                cmd,
                text=True,
                capture_output=True,
                check=True
            )
            return yaml.safe_load(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error fetching OCI chart: {e.stderr}")
            sys.exit(1)

    def sync(self):
        """Main execution flow to export env vars and update Chart.yaml."""
        oci_params = self.get_remote_oci_metadata()
        print(f"OCI: params:{oci_params}")

        if "dependencies" in self.local_data and len(self.local_data["dependencies"]) > 0:
            # We map appVersion from OCI to the dependency version, 
            # and the OCI version to the local chart version.
            self.local_data["dependencies"][0]["version"] = oci_params.get("appVersion")
            self.local_data["version"] = oci_params.get("version")
            
            with open(self.oci_chart_file, 'w') as f:
                yaml.safe_dump(self.local_data, f, sort_keys=False)

def parse_cli_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Manage Helm OCI parameters and Chart.yaml updates")
    parser.add_argument("-o", "--oci", required=True, help="OCI path (e.g., oci://registry/chart)")
    parser.add_argument("-c", "--chart-file", required=True, help="Path to local Chart.yaml")
    parser.add_argument("--devel", action="store_true", help="Use development versions (helm show chart --devel)")
    return parser.parse_args()

def main():
    args = parse_cli_args()
    
    helm = HelmChart(
        oci_chart_file=args.chart_file, 
        oci_path=args.oci,
        devel=args.devel
    )
    
    helm.sync()
    print(f"Successfully synced using {'development' if args.devel else 'stable'} versions.")

if __name__ == "__main__":
    main()