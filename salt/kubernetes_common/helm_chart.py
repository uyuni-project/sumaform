import subprocess
import yaml
import argparse

class HelmChart:
    """Class to get information about a helm oci"""

    def __init__(self, oci_chart_file: str, oci_path: str, file_output: str):
        self.oci_path = oci_path
        self.file_output = file_output
        self.oci_chart_file = oci_chart_file

    def _read_yaml(self, file):
        data = {}
        with open(file, 'r') as f:
            data = yaml.safe_load(f)
        return data

    def _write_yaml(self, file, content_to_replace):
        with open(file, 'w') as f:
            yaml.safe_dump(content_to_replace, f, sort_keys=False)

    def _write_text_in_file(self, text, file):
        with open(file, "w") as f:
            f.write(text)

    def get_name_from_yaml(self):
        dependencies = self.data.get('dependencies')[0]
        return dependencies['name']

    def get_oci_path_from_yaml(self):
        dependencies = self.data.get('dependencies')[0]
        return dependencies['repository']

    def get_version_from_yaml(self):
        dependencies = self.data.get('dependencies')[0]
        return dependencies['version']

    def get_parameters_of_oci_from_chart(self):
        result = subprocess.run(["helm", "show", "chart", self.oci_path],
                                text=True,
                                capture_output=True,
                                check=True)
        oci_parameters = yaml.safe_load(result.stdout)
        return oci_parameters

    def set_oci_parameters_as_env_variables(self):
        oci_parameters = self.get_parameters_of_oci_from_chart()
        lines = [f'export {k}="{v}"' for k, v in oci_parameters.items()]
        content = "\n".join(lines) + "\n"
        self._write_text_in_file(content, self.file_output)

    def set_oci_parameters_in_chart_file(self):
        oci_parameters = self.get_parameters_of_oci_from_chart()
        chart_content = self._read_yaml(self.oci_chart_file)
        chart_content["dependencies"][0]["version"] = oci_parameters["appVersion"]
        chart_content["version"] = oci_parameters["version"]
        self._write_yaml(self.oci_chart_file, chart_content)


def parse_cli_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="This scripts manages the uyuni yaml files"
    )
    parser.add_argument("-o", "--oci", required=True, dest="oci", help="OCI to retrieve the parameters from.", action='store')
    parser.add_argument("-f", "--file-output", required=True, dest="file_output", help="File where to set the variables.", action='store')
    parser.add_argument("-c", "--chart-file", required=True, dest="chart_file", help="Path to the Chart.yaml file.", action='store')
    return parser.parse_args()

def main():
    args: argparse.Namespace = parse_cli_args()
    helm = HelmChart(args.chart_file, args.oci, args.file_output)
    helm.set_oci_parameters_as_env_variables()
    helm.set_oci_parameters_in_chart_file()

if __name__ == "__main__":
    main()
