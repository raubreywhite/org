#' Create example project that uses quarto with results generated from within the .qmd file
#' @param home Location of the 'home' directory.
#' @param results Location of the 'results' directory.
#' @export
create_project_quarto_internal_results <- function(
  home,
  results
  ) {
  if(file.exists(path(home))){
    stop(home, " already exists. Please delete it if you want to continue.")
  }
  create_dir(path(home))
  create_dir(path(home, "R"))
  create_dir(path(home, "quarto"))
  create_dir(path(results))

  # delete some files if not needed
  unlink(ls_files(home, regexp = "*Rproj$"))

  ############
  # .gitignore
  cat_to_gitignore <- cat_to_filepath_function_factory(path(home, ".gitignore"))

  cat_to_gitignore(".Rhistory", "\n", append = FALSE)
  cat_to_gitignore(".Rapp.history", "\n")
  cat_to_gitignore(".RData", "\n")
  cat_to_gitignore(".Ruserdata", "\n")
  cat_to_gitignore(".Rproj.user/", "\n")

  ############
  # run.R
  cat_to_run_r <- cat_to_filepath_function_factory(path(home, "run.R"))

  cat_to_run_r("# initialize the project", "\n", append = FALSE)
  cat_to_run_r("# note: remember to keep in sync with quarto/quarto.qmd", "\n")
  cat_to_run_r("project <- org::initialize_project(", "\n")
  cat_to_run_r("  env     = .GlobalEnv,", "\n")
  cat_to_run_r("  home    = \"", home, "\",", "\n")
  cat_to_run_r("  quarto  = \"", path(home, "quarto"), "\",", "\n")
  cat_to_run_r("  results = \"", results, "\",", "\n")
  cat_to_run_r("  folders_to_be_sourced = \"R\"", "\n")
  cat_to_run_r(")", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# render the quarto doc", "\n")
  cat_to_run_r("quarto::quarto_render(", "\n")
  cat_to_run_r("  input = org::path(project$quarto), # not org::project here!", "\n")
  cat_to_run_r("  quiet = FALSE", "\n")
  cat_to_run_r(")", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# move the rendered folder to results", "\n")
  cat_to_run_r("# note: \"rendered_quarto\" is specified in quarto/_quarto.yml", "\n")
  cat_to_run_r("org::move_directory(", "\n")
  cat_to_run_r("  from = org::path(org::project$quarto, \"rendered_quarto\"),", "\n")
  cat_to_run_r("  to = org::path(org::project$results_today, \"rendered_quarto\"),", "\n")
  cat_to_run_r("  overwrite_to = TRUE", "\n")
  cat_to_run_r(")", "\n")

  ############
  # quarto/.gitignore
  cat_to_quarto_gitignore <- cat_to_filepath_function_factory(path(home, "quarto", ".gitignore"))

  cat_to_quarto_gitignore("rendered_quarto", "\n", append = FALSE)

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
  cat_to_quarto_yml("  docx:", "\n")
  cat_to_quarto_yml("    default", "\n")

  ############
  # quarto/quarto.qmd
  cat_to_quarto_qmd <- cat_to_filepath_function_factory(path(home, "quarto", "quarto.qmd"))

  cat_to_quarto_qmd("---", "\n", append = FALSE)
  cat_to_quarto_qmd("title: \"Title\"", "\n")
  cat_to_quarto_qmd("author: \"Author\"", "\n")
  cat_to_quarto_qmd("editor_options:", "\n")
  cat_to_quarto_qmd("  chunk_output_type: console", "\n")
  cat_to_quarto_qmd("---", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("```{r}", "\n")
  cat_to_quarto_qmd("#| include: false", "\n")
  cat_to_quarto_qmd("# initialize the project", "\n")
  cat_to_quarto_qmd("# note: remember to keep in sync with run.R", "\n")
  cat_to_quarto_qmd("org::initialize_project(\n")
  cat_to_quarto_qmd("  env     = .GlobalEnv,", "\n")
  cat_to_quarto_qmd("  home    = \"", home, "\",", "\n")
  cat_to_quarto_qmd("  quarto  = \"", path(home, "quarto"), "\",", "\n")
  cat_to_quarto_qmd("  results = \"", results, "\",", "\n")
  cat_to_quarto_qmd("  folders_to_be_sourced = \"R\"", "\n")
  cat_to_quarto_qmd(")\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("library(data.table)\n")
  cat_to_quarto_qmd("library(ggplot2)\n")
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

#' Create example project that uses quarto with results generated outside the .qmd file
#' @param home Location of the 'home' directory.
#' @param results Location of the 'results' directory.
#' @export
create_project_quarto_external_results <- function(
    home,
    results
) {
  if(file.exists(path(home))){
    stop(home, " already exists. Please delete it if you want to continue.")
  }
  create_dir(path(home))
  create_dir(path(home, "R"))
  create_dir(path(home, "quarto"))
  create_dir(path(results))

  # delete some files if not needed
  unlink(ls_files(home, regexp = "*Rproj$"))

  ############
  # .gitignore
  cat_to_gitignore <- cat_to_filepath_function_factory(path(home, ".gitignore"))

  cat_to_gitignore(".Rhistory", "\n", append = FALSE)
  cat_to_gitignore(".Rapp.history", "\n")
  cat_to_gitignore(".RData", "\n")
  cat_to_gitignore(".Ruserdata", "\n")
  cat_to_gitignore(".Rproj.user/", "\n")

  ############
  # run.R
  cat_to_run_r <- cat_to_filepath_function_factory(path(home, "run.R"))

  cat_to_run_r("# initialize the project", "\n", append = FALSE)
  cat_to_run_r("# note: remember to keep in sync with quarto/quarto.qmd", "\n")
  cat_to_run_r("project <- org::initialize_project(", "\n")
  cat_to_run_r("  env     = .GlobalEnv,", "\n")
  cat_to_run_r("  home    = \"", home, "\",", "\n")
  cat_to_run_r("  quarto  = \"", path(home, "quarto"), "\",", "\n")
  cat_to_run_r("  results = \"", results, "\",", "\n")
  cat_to_run_r("  folders_to_be_sourced = \"R\"", "\n")
  cat_to_run_r(")", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("library(data.table)", "\n")
  cat_to_run_r("library(ggplot2)", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("results <- list()", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# figure 1", "\n")
  cat_to_run_r("pd <- data.frame(x = 1:10, y = 1:10)", "\n")
  cat_to_run_r("q <- ggplot(pd, aes(x = x, y = y))", "\n")
  cat_to_run_r("q <- q + geom_point()", "\n")
  cat_to_run_r("filepath <- org::path(org::project$results_today, \"fig_01.png\")", "\n")
  cat_to_run_r("ggsave(filepath, plot = q, width = 297, height = 210, units =\"mm\")", "\n")
  cat_to_run_r("results$fig_01_filepath <- filepath", "\n")
  cat_to_run_r("results$fig_01 <- q", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# save results", "\n")
  cat_to_run_r("saveRDS(results, org::path(org::project$results_today, \"results.rds\"))", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# render the quarto doc", "\n")
  cat_to_run_r("quarto::quarto_render(", "\n")
  cat_to_run_r("  input = org::path(project$quarto), # not org::project here!", "\n")
  cat_to_run_r("  quiet = FALSE", "\n")
  cat_to_run_r(")", "\n")
  cat_to_run_r("\n")
  cat_to_run_r("# move the rendered folder to results", "\n")
  cat_to_run_r("# note: \"rendered_quarto\" is specified in quarto/_quarto.yml", "\n")
  cat_to_run_r("org::move_directory(", "\n")
  cat_to_run_r("  from = org::path(org::project$quarto, \"rendered_quarto\"),", "\n")
  cat_to_run_r("  to = org::path(org::project$results_today, \"rendered_quarto\"),", "\n")
  cat_to_run_r("  overwrite_to = TRUE", "\n")
  cat_to_run_r(")", "\n")

  ############
  # quarto/.gitignore
  cat_to_quarto_gitignore <- cat_to_filepath_function_factory(path(home, "quarto", ".gitignore"))

  cat_to_quarto_gitignore("rendered_quarto", "\n", append = FALSE)

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
  cat_to_quarto_yml("  docx:", "\n")
  cat_to_quarto_yml("    default", "\n")

  ############
  # quarto/quarto.qmd
  cat_to_quarto_qmd <- cat_to_filepath_function_factory(path(home, "quarto", "quarto.qmd"))

  cat_to_quarto_qmd("---", "\n", append = FALSE)
  cat_to_quarto_qmd("title: \"Title\"", "\n")
  cat_to_quarto_qmd("author: \"Author\"", "\n")
  cat_to_quarto_qmd("editor_options:", "\n")
  cat_to_quarto_qmd("  chunk_output_type: console", "\n")
  cat_to_quarto_qmd("---", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("```{r}", "\n")
  cat_to_quarto_qmd("#| include: false", "\n")
  cat_to_quarto_qmd("# initialize the project", "\n")
  cat_to_quarto_qmd("# note: remember to keep in sync with run.R", "\n")
  cat_to_quarto_qmd("org::initialize_project(\n")
  cat_to_quarto_qmd("  env     = .GlobalEnv,", "\n")
  cat_to_quarto_qmd("  home    = \"", home, "\",", "\n")
  cat_to_quarto_qmd("  quarto  = \"", path(home, "quarto"), "\",", "\n")
  cat_to_quarto_qmd("  results = \"", results, "\",", "\n")
  cat_to_quarto_qmd("  folders_to_be_sourced = \"R\"", "\n")
  cat_to_quarto_qmd(")\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("library(data.table)\n")
  cat_to_quarto_qmd("library(ggplot2)\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("results <- readRDS(org::path(org::project$results_today, \"results.rds\"))\n")
  cat_to_quarto_qmd("```", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("## Quarto", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("Quarto enables you to weave together content and executable code into a finished document. To learn more about Quarto see <https://quarto.org>.", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("## Importing graphs", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("When you click the **Render** button a document will be generated that includes both content and the output of embedded code. You can embed code like this:", "\n")
  cat_to_quarto_qmd("\n")
  cat_to_quarto_qmd("```{r}", "\n")
  cat_to_quarto_qmd("#| echo: false", "\n")
  cat_to_quarto_qmd("results$fig_01", "\n")
  cat_to_quarto_qmd("```", "\n")
  cat_to_quarto_qmd("\n")

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
