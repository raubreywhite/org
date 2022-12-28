#' Create example project that uses quarto
#' @param home Location of the 'home' directory.
#' @param results Location of the 'results' directory.
#' @export
create_project_quarto <- function(
  home,
  results
  ) {
  create_dir(path(home))
  create_dir(path(home, "R"))
  create_dir(path(home, "quarto"))
  create_dir(path(results))

  # delete some files if not needed
  unlink(ls_files(home, regexp = "*Rproj$"))

  ############
  # run.R
  cat_to_run_r <- cat_to_filepath_function_factory(path(home, "run.R"))

  cat_to_run_r("# initialize the project", "\n", append = FALSE)
  cat_to_run_r("# note: remember to keep in sync with quarto/quarto.qmd", "\n")
  cat_to_run_r("org::initialize_project(", "\n")
  cat_to_run_r("  env     = \".GlobalEnv\",", "\n")
  cat_to_run_r("  home    = \"", home, "\",", "\n")
  cat_to_run_r("  quarto  = \"", path(home, "quarto"), "\",", "\n")
  cat_to_run_r("  results = \"", results, "\",", "\n")
  cat_to_run_r("  create_folders = TRUE", "\n")
  cat_to_run_r(")", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# render the quarto doc", "\n")
  cat_to_run_r("quarto::quarto_render(", "\n")
  cat_to_run_r("  input = org::path(org::project$quarto),", "\n")
  cat_to_run_r("  quiet = FALSE", "\n")
  cat_to_run_r(")", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# move the rendered folder to results", "\n")
  cat_to_run_r("# note: \"rendered_quarto\" is specified in quarto/_quarto.yml", "\n")
  cat_to_run_r("org::move_file_or_dir(", "\n")
  cat_to_run_r("  from = org::path(org::project$quarto, \"rendered_quarto\"),", "\n")
  cat_to_run_r("  to = org::path(org::project$results_today, \"rendered_quarto\")", "\n")
  cat_to_run_r(")", "\n")

  ############
  # quarto/_quarto.yml
  cat_to_quarto_yml <- cat_to_filepath_function_factory(path(home, "quarto", "_quarto.yml"))

  cat_to_quarto_yml("project:", "\n", append = FALSE)
  cat_to_quarto_yml("  output-dir: rendered_quarto", "\n")
  cat_to_quarto_yml("\n")
  cat_to_quarto_yml("toc: true", "\n")
  cat_to_quarto_yml("number-sections: true", "\n")
  cat_to_quarto_yml("\n")
  cat_to_quarto_yml("format:", "\n")
  cat_to_quarto_yml("  pdf:", "\n")
  cat_to_quarto_yml("    documentclass: report", "\n")

  ############
  # quarto/quarto.qmd
  cat_to_quarto_qmd <- cat_to_filepath_function_factory(path(home, "quarto", "quarto.qmd"))

  cat_to_quarto_qmd("---", "\n", append = FALSE)
  cat_to_quarto_qmd("title: \"Untitled\"", "\n")
  cat_to_quarto_qmd("---", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("```{r}", "\n")
  cat_to_quarto_qmd("#| include: false", "\n")
  cat_to_quarto_qmd("# initialize the project\n", append = FALSE)
  cat_to_quarto_qmd("# note: remember to keep in sync with run.R\n")
  cat_to_quarto_qmd("org::initialize_project(\n")
  cat_to_quarto_qmd("  home    = \"", home, "\",\n")
  cat_to_quarto_qmd("  quarto  = \"", path(home, "quarto"), "\",\n")
  cat_to_quarto_qmd("  results = \"", results, "\",\n")
  cat_to_quarto_qmd("  create_folders = TRUE\n")
  cat_to_quarto_qmd(")\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("library(ggplot2)\n")
  cat_to_quarto_qmd("library(data.table)\n")
  cat_to_quarto_qmd("```", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("## Quarto", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("Quarto enables you to weave together content and executable code into a finished document. To learn more about Quarto see <https://quarto.org>.", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("## Running Code", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("When you click the **Render** button a document will be generated that includes both content and the output of embedded code. You can embed code like this:", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("```{r}", "\n")
  cat_to_quarto_qmd("1 + 1", "\n")
  cat_to_quarto_qmd("```", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("You can add options to executable code like this", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("```{r}", "\n")
  cat_to_quarto_qmd("#| echo: false", "\n")
  cat_to_quarto_qmd("2 * 2", "\n")
  cat_to_quarto_qmd("```", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("The `echo: false` option disables the printing of code (only output is displayed).", "\n")

  ############
  # project.Rproj
  cat_to_project_rproj<- cat_to_filepath_function_factory(path(home, "project.Rproj"))

  cat_to_project_rproj("Version: 1.0", "\n", append = FALSE)
  cat_to_project_rproj("\n")
  cat_to_project_rproj("RestoreWorkspace: No", "\n")
  cat_to_project_rproj("SaveWorkspace: No", "\n")
  cat_to_project_rproj("AlwaysSaveHistory: Default", "\n")

  if(package_installed("rstudioapi")){
    if(rstudioapi::isAvailable() & interactive()){
      rstudioapi::openProject(path(home, "project.Rproj"))
    }
  }
}
