#' Distance between two geographic entities
#'
#' This function allows you to get distances between two geographic entities.
#'
#' @param origin Vector containing origin entities. (character)
#' @param destination Vector containing destination entities. (character)
#' @param theta Vector containing theta value between -1 and 1, defaults to -1 for the harmonic mean. Set to 0 for geometric mean, 1 for arithmetic mean. (numeric)
#' @param year Vector containing years between 1992 and 2012, defaults to 2012 (numeric)
#' @param data Data.table with computed distances, defaults to gravity.distances::distances_data
#' @param code_format Character string indicating format of origin and destination corresponding to the countrycode package. Defaults to "iso3c".
#' @param data_url Character string indicating url from which data should be downloaded.
#' @param data_store Logical indicator whether downloaded data should be stored permanently.
#' @keywords distances
#' @import data.table
#' @import countrycode
#' @export get_distance
#' @examples
#' get_distance("DEU", "CAN")

get_distance = function (origin, destination, year = 2012, theta = -1,
                         data = NULL, code_format = "iso3c",
                         data_url = "https://raw.githubusercontent.com/julianhinz/gravity.distances_data/master/",
                         data_store = T) {

  # perform sanity checks
  if (sum(!year %in% c(1992:2012)) > 0) print("Warning: Currently distances are only available for years between 1992 and 2012")
  if (sum(theta < -1 | theta > 1) > 0)  print("Warning: Currently distances are only available for thetas between -1 and 1")

  # set request
  request = data.table(id = 1:length(origin),
                       year = as.character(year),
                       origin = as.character(origin),
                       destination = as.character(destination),
                       theta = as.character(theta))
  if (code_format != "iso3c") {
    request[, origin := countrycode(origin, code_format, "iso3c")]
    request[, destination := countrycode(destination, code_format, "iso3c")]
  }

  # set data
  if (is.null(data)) data = gravity.distances::distances_data
  if (is.character(data) && data %in% c("distances_from_countries_to_countries",
                                        "distances_from_usa_states_to_countries",
                                        "distances_from_usa_states_to_usa_states",
                                        "distances_from_canada_provinces_to_countries",
                                        "distances_from_canada_provinces_to_canada_provinces",
                                        "distances_from_canada_provinces_to_usa_states")) {
    data = get_data(data,
                    years = unique(request[year %in% c(1992:2012)]$year),
                    data_url,
                    data_store)
  }

  # subset data for faster matching
  data = data[year %in% unique(request$year)]
  data = data[theta %in% unique(request$theta)]

  # make sure types are okay
  data = data[, .(year = as.character(year),
                  origin = as.character(origin),
                  destination = as.character(destination),
                  theta = as.character(theta),
                  value = as.numeric(value))]

  # get output and return
  output = merge(request, data, all.x = T,
                 by = c("origin", "destination", "theta", "year"))[order(id)]$value
  return(output)
}


#' Get additional distances datasets
#'
#' Provides distances data from additional available downloadable datasets
#'
#' @param data Character string containing name of dataset
#' @param years Vector of years for which data is requested (character)
#' @param data_url Character string indicating url from which data should be downloaded.
#' @param data_store Logical indicator whether downloaded data should be stored permanently.
#' @import data.table
#' @import feather
#' @import stringr
#' @import utils
#'
get_data = function (data, years, data_url, data_store) {

  # needed data_years
  data_years = str_c(data, "_", years, ".feather")

  # check data is available, otherwise download
  for (i in 1:length(data_years)) {
    if (!file.exists(str_c("data/", data, "/", data_years[i]))) {
      if (!dir.exists(str_c("data/", data, "/"))) dir.create(str_c("data/", data, "/"))
      download.file(url = str_c(data_url, data, "/", data_years[i], ".zip"),
                    destfile = str_c("data/", data, "/", data_years[i], ".zip"), quiet = F)
      unzip(zipfile = str_c("data/", data, "/", data_years[i], ".zip"),
            exdir = str_c("data/", data, "/"))
      unlink(str_c("data/", data, "/", data_years[i], ".zip"))
    }
  }

  # load data and combine in single data.table
  output = data.table()
  for (i in 1:length(data_years)) {
    output = rbind(output, read_feather(str_c("data/", data, "/", data_years[i])))
  }

  # delete files if data should not be stored
  if (!data_store) unlink(str_c("data/", data, "/"), recursive = T)

  # return data
  return(output)
}

#' Remove some or all downloaded additional distances datasets
#'
#' @param data Character string or vector containing name of dataset(s)
#' @import stringr
#' @export remove_data
#' @examples
#' remove_data("distances_from_canada_provinces_to_canada_provinces")
#'
remove_data = function (data = NULL) {
  datasets = list.dirs(str_c("data"))
  datasets = datasets[datasets != "data"]
  if (!is.null(data)) datasets = datasets[str_detect(datasets, data)]
  unlink(datasets, recursive = T)
  print(str_c("Removed ", str_c(datasets, collapse = ", ")))
}
