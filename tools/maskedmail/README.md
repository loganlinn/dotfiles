# fastmail-masked-email

[![PyPI](https://img.shields.io/pypi/v/fastmail-masked-email.svg)](https://pypi.org/project/fastmail-masked-email/)
[![Changelog](https://img.shields.io/github/v/release/loganlinn/fastmail-masked-email?include_prereleases&label=changelog)](https://github.com/loganlinn/fastmail-masked-email/releases)
[![Tests](https://github.com/loganlinn/fastmail-masked-email/actions/workflows/test.yml/badge.svg)](https://github.com/loganlinn/fastmail-masked-email/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/loganlinn/fastmail-masked-email/blob/master/LICENSE)



## Installation

Install this tool using `pip`:
```bash
pip install fastmail-masked-email
```
## Usage

For help, run:
```bash
fastmail-masked-email --help
```
You can also use:
```bash
python -m fastmail_masked_email --help
```
## Development

To contribute to this tool, first checkout the code. Then create a new virtual environment:
```bash
cd fastmail-masked-email
python -m venv venv
source venv/bin/activate
```
Now install the dependencies and test dependencies:
```bash
pip install -e '.[test]'
```
To run the tests:
```bash
python -m pytest
```
