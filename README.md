# org <a href="https://www.rwhite.no/org/"><img src="man/figures/logo.png" align="right" width="120" /></a>

[![CRAN status](https://www.r-pkg.org/badges/version/org)](https://cran.r-project.org/package=org)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/org)](https://cran.r-project.org/package=org)

## Overview

[org](https://www.rwhite.no/org/) is a framework for organizing R projects with a standardized structure. It helps manage the three main components of most analyses:

- **Code**: Version-controlled analysis scripts
- **Results**: Date-organized output files
- **Data**: Securely stored input data

Each component has specific requirements and best practices that `org` helps enforce. The package provides tools to:

- Set up and manage project directories
- Handle file paths consistently across operating systems
- Manage results with date-based organization
- Source code from specified directories
- Create and manage Quarto documents
- Handle file operations safely

## Installation from CRAN

```r
install.packages("org")
```

## Getting started

1. Read the [introduction vignette](https://www.rwhite.no/org/articles/org.html)
2. Run `help(package="org")` for detailed function documentation

## Quick example

```r
# Initialize a new project
org::initialize_project(
  env = .GlobalEnv,
  home = "/path/to/project",      # Contains Run.R and R/ folder
  results = "/path/to/results",   # Where results will be stored
  data_raw = "/path/to/data"      # Raw data location
)

# Access project settings
org::project$results_today  # Today's results folder
org::project$data_raw      # Raw data folder
```

## Contributing

Contributions are welcome! Please feel free to submit a [Pull Request](https://github.com/raubreywhite/org/pulls).

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
