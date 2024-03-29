path = getwd()
setwd(file.path(path))
base_path = dirname(path)


args = commandArgs(trailingOnly=TRUE)


if (length(args) < 3){
  print("Expects at-least 3 arguments, as follows:")
  print("if the program is already running: yes/no")
  print("Name of the outut directory: my_out_dir")
  print("Name of the input file (in this case, it's fixes): 308_full.csv")
  print("Whether upsampling is required: TRUE/FALSE")
  print()
  print("Here is a sample run (you can copy and paste it in the terminal directly to run the program)")
  print("Rscript classificationPipeline.R no test_output 308_full.csv TRUE")
  stop(exiting)
}



already_running = args[1]
result_dir_name = args[2]
input_file_name = args[3]
upsample = args[4]


# already_running = "no"
# result_dir_name = "test_results"
# input_file_name = "308_full.csv"
# upsample = "TRUE"


out_dir = file.path(base_path, result_dir_name)


if ( (dir.exists(out_dir)) && (already_running == "no") ){
  time_stamp = format(Sys.time(), "%m_%d_%H-%m-%S")
  new_name = paste(out_dir, "_old_", time_stamp, sep="")
  file.rename(out_dir, new_name)
  dir.create(out_dir)
} else if ( !(dir.exists(out_dir)) && (already_running == "no") ){
  dir.create(out_dir)
}


print(paste("Started execution on:", Sys.time()))


print("###################################")
print("1 Install packages")
print("###################################")


source("InstallMissingPackages.R")
source("visualizeTopResults.R")
source("visualizeAllResults.R")


availableModels = install_missing_packages(file.path("classModelList.txt"))


print("###################################")
print("2 READ/COMBINE DATA")
print("###################################")


source("DataIO.R")

out <- load_data(file.path(base_path, "data", input_file_name), upsample)

train_data <- out[[1]]
test_data <- out[[2]]
test_data$target <- as.factor(test_data$target)


source("runModels.R")


# Set parameters
time_limit = 1000
number <- 5
repeats <- 1
num_mdls <- 0
show_top <- 10


# Test parameters
# time_limit = 1000
# number <- 5
# repeats <- 5
# num_mdls <- 2
# show_top <- 10

  
  print("###################################")
  print("3 RUN MODELS FOR dBG Motif Based Classification")
  print("###################################")
  
  train_out_file = "train_results.csv"
  test_out_file = "test_results.csv"
  stat_file = "Timp_stat.csv"
  plot_file = "Timp.png"
  
  trainFilePath = file.path(out_dir, train_out_file)
  testFilePath = file.path(out_dir, test_out_file)
  
  runModels(availableModels, train_data, test_data, time_limit, 
            number, repeats, out_dir, train_out_file, test_out_file, stat_file, num_mdls)
  
  trainFilePath = file.path(out_dir, train_out_file)
  testFilePath = file.path(out_dir, test_out_file)
  
  # if (file.exists(trainFilePath) && (file.exists(testFilePath))){
  #   trainData <- read.csv2(file = trainFilePath, stringsAsFactors = FALSE, sep=",")
  #   testData <- read.csv2(file = testFilePath, stringsAsFactors = FALSE, sep=",")
  # 
  #   # plot top 30 models
  #   drawPlots(trainData, testData, "TIMP", out_dir, plot_file, show_top)
  # 
  #   # plot all models
  #   drawAllPlots(trainData, testData, "TIMP", out_dir)
  # 
  # } else{
  #   print("Results could not be located! Please check if the run was completed.")
  # }


print(paste("Completed execution on:", Sys.time()))

