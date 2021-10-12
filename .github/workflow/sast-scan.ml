name: SAST-scan

on: [push]

jobs:
  sobelow_job:
    runs-on: ubuntu-latest
    name: Sobelow Job
    steps:
      - uses: actions/checkout@v2
      - id: run-action
        uses: sobelow/action@v1
      - uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: results.sarif