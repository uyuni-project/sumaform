import subprocess
import yaml
import argparse

class helm_chart:
    """Class to get information about uyuni charts"""

    def __init__(self, chart_file: str):
        self.file_path = chart_file
        self.data = self._read_yaml(chart_file)

    def _read_yaml(self, file):
        data = {}
        with open(file, 'r') as f:
            try:
                data = yaml.safe_load(f)
            except yaml.YAMLError as error:
                print(f"Error: {error} reading the yaml file: {file}")
                raise yaml.YAMLError
        return data

    def _write_yaml(self, file, content_to_replace):
        with open(file, 'w') as f:
            yaml.safe_dump(content_to_replace, f, sort_keys=False)

    def get_name(self):
        dependencies = self.data.get('dependencies')[0]
        return dependencies['name']

    def get_oci_path(self):
        dependencies = self.data.get('dependencies')[0]
        return dependencies['repository']

    def get_version(self):
        dependencies = self.data.get('dependencies')[0]
        return dependencies['version']

    def set_last_version_of_appVersion_in_oci(self):
        oci = self.get_oci_path()
        name = self.get_name()
        oci = oci + "/" + name
        result = subprocess.run(["helm", "show", "chart", oci],
                                text=True,
                                capture_output=True,
                                check=True)
        chart_yaml = yaml.safe_load(result.stdout)
        self.data["dependencies"][0]["version"] = chart_yaml["appVersion"]
        self._write_yaml(self.file_path, self.data)

def parse_cli_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="This scripts manages the uyuni yaml files"
    )
    parser.add_argument("-p", "--path", required=True, dest="path", help="Path where yaml is located", action='store')
    return parser.parse_args()

def main():
    args: argparse.Namespace = parse_cli_args()
    helm = helm_chart(args.path)
    helm.set_last_version_of_appVersion_in_oci()

if __name__ == "__main__":
    main()
