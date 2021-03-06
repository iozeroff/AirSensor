#' @keywords pa_timeseries
#' @export
#' @importFrom rlang .data
#' @importFrom stats aggregate median na.omit quantile sd t.test time
#'
#' @title Aggregation statistics for PurpleAir Timeseries objects
#' 
#' @param pat PurpleAir Timeseries \emph{pat} object.
#' @param period Time period to average to. Can be "sec", "min", "hour", 
#' "day", "DSTday", "week", "month", "quarter" or "year". A number can also
#'  precede these options followed by a space (i.e. "2 day" or "37 min").
#' 
#' @description Calculates statistics associated with the aggregation of raw 
#' PurpleAir Timeseries data onto a regular time axis.
#' 
#' Temporal aggregation involves creating time period bins defined by
#' \code{period} and then calculating the statistics associated with the raw
#' data measurements that fall within each bin. The result is a dataframe with
#' a regular time axis and multiple columns of output for every column of
#' input.
#' 
#' Each of the \emph{pat} object data columns will result in the following
#' basic statistics:
#' 
#' \enumerate{
#' \item{\code{mean}}
#' \item{\code{median}}
#' \item{\code{sd}}
#' \item{\code{min}}
#' \item{\code{max}}
#' \item{\code{count}}
#' }
#' 
#' For the paired \code{pm25_A} and \code{pm25_B} data columns, the following 
#' additional statistics are generated by applying a two-sample t-test to the 
#' A and B channel data in each bin:
#' 
#' \enumerate{
#' \item{\code{pm25_t} -- t-test statistic}
#' \item{\code{pm25_p} -- p-value}
#' \item{\code{pm25_df} -- degrees of freedom}
#' }
#' 
#' These statistics are used to assign aggregate (hourly) values, (\emph{e.g.}
#' \code{temperature_mean}). They can also be used to invalidate some aggregate 
#' values based on \code{sd}, \code{count} or \code{pm25_t}.
#' 
#' @return Returns a dataframe with aggregation statistics.
#' 
#' @examples
#' \dontrun{
#' df <- pat_aggregate(example_pat, "1 hour")
#' head(df)
#' }

pat_aggregate <- function(
  pat = NULL, 
  period = "1 hour"
) {
  
  # ----- Validate parameters --------------------------------------------------

  period <- tolower(period)
  
  MazamaCoreUtils::stopIfNull(pat)
  
  if ( !pat_isPat(pat) )
    stop("Required parameter 'pat' is not a valid 'pa_timeseries' object.")
  
  if ( pat_isEmpty(pat) )
    stop("Required parameter 'pat' has no data.") 
  
  # Remove any duplicate data records
  pat <- pat_distinct(pat)
  
  # ----- Convert period to seconds --------------------------------------------
  
  periodParts <- strsplit(period, " ", fixed = TRUE)[[1]]
  
  if ( length(periodParts) == 1 ) {
    periodCount <- 1
    units <- periodParts[1]
  } else {
    periodCount <- as.numeric(periodParts[1])
    units <- periodParts[2]
  }
  
  if ( units == "sec"     ) unitSecs <- 1
  if ( units == "min"     ) unitSecs <- 60
  if ( units == "hour"    ) unitSecs <- 3600
  if ( units == "day"     ) unitSecs <- 3600 * 24
  if ( units == "week"    ) unitSecs <- 3600 * 24 * 7
  if ( units == "month"   ) unitSecs <- 3600 * 24 * 31
  if ( units == "quarter" ) unitSecs <- 3600 * 24 * 31 * 3
  if ( units == "year"    ) unitSecs <- 3600 * 8784 
  
  periodSeconds <- periodCount * unitSecs 
  
  # ---- Calculate aggregation statistics --------------------------------------
  
  # Parameters for all numeric 
  parameters <- c("pm25_A", "pm25_B", "humidity", "temperature")
  
  # Parameters for T-test 
  t_parameters <- c("pm25_A", "pm25_B")
  
  # NOTE:  base::Reduce() is rarely seen in modern R code but the implementation
  # NOTE:  below is remarkably fast. See ?Reduce for details on base R support
  # NOTE:  for functional programming.
  
  # Apply .pat_agg separately for each type of stat -> 
  # Reduce list by merging to common (datetime)
  aggregationStats <- 
    Reduce(
      f = function(...) merge(..., all=TRUE), 
      x = list(    
        .pat_agg(pat, "tstats", periodSeconds, t_parameters),
        .pat_agg(pat, "mean", periodSeconds, parameters),
        .pat_agg(pat, "median", periodSeconds, parameters),
        .pat_agg(pat, "sd", periodSeconds, parameters), 
        .pat_agg(pat, "min", periodSeconds, parameters), 
        .pat_agg(pat, "max", periodSeconds, parameters),
        .pat_agg(pat, "count", periodSeconds, parameters)
      )
    )
  
  # Re-arrange order of columns to group by input column
  aggregationStats <-
    aggregationStats[, c( "datetime",
                          names(aggregationStats)
                          [c( grep("pm25_", names(aggregationStats)),
                              grep("humid", names(aggregationStats)),
                              grep("temp", names(aggregationStats)) )] )]
  
  # ----- Return ---------------------------------------------------------------
  
  return(aggregationStats)
  
}

# ===== INTERNAL FUNCTION ======================================================

#' @keywords internal
#' 
.pat_agg <- function(pat, stat, periodSeconds, parameters) {
  
  options(warn = -1) # Ignore all warnings
  
  if ( stat == "mean"       ) func <- function(x) mean(x, na.rm = TRUE)
  if ( stat == "median"     ) func <- function(x) median(x, na.rm = TRUE) 
  if ( stat == "count"      ) func <- function(x) length(na.omit(x))
  if ( stat == "sd"         ) func <- function(x) sd(x, na.rm = TRUE)
  if ( stat == "sum"        ) func <- function(x) sum(na.omit(x))
  if ( stat == "max"        ) func <- function(x) max(na.omit(x))
  if ( stat == "min"        ) func <- function(x) min(na.omit(x))
  if ( stat == "tstats"     ) func <- function(x) list(x) 
  
  # Remove duplicated time entries and create datetime axis (if any)
  datetime <- 
    pat$data$datetime[which(!duplicated.POSIXlt(pat$data$datetime))]
  
  # Create data frame 
  data <- data.frame(pat$data)[, parameters]
  
  # zoo with datetime index 
  zz <- zoo::zoo(data, order.by = datetime)
  
  # NOTE:  Calling aggregate() will dispatch to aggregate.zoo() because the
  # NOTE:  argument is a "zoo" object. Unfortunately, we cannot call 
  # NOTE:  zoo::aggregate.zoo() explicitly because this function is not
  # NOTE:  exported by the zoo package.
  
  # Aggregate
  zagg <- 
    aggregate(
      zz, 
      by = time(zz) - as.numeric(time(zz)) %% periodSeconds, 
      FUN = func
    )  
  
  # ----- !T-test --------------------------------------------------------------
  
  if ( stat != "tstats" ) {
    
    # Fortify to data.frame
    tbl <- zoo::fortify.zoo(zagg, names = "datetime")
    
    # Rename 
    colnames(tbl)[-1] <- paste0(colnames(tbl)[-1], "_", stat)
    
    return(tbl)
    
  }
  
  # ----- T-test ---------------------------------------------------------------
  
  if ( stat == "tstats" ) {
    
    # Internal t.test function that will always respond, even in the face of 
    # problematic data.
    .ttest <- function(x, y) {
      
      if ( length(na.omit(x)) <= 2 || length(na.omit(y)) <= 2 ) {
        # Not enough valid data
        return(t.test(c(0,0,0), c(0,0,0)))
      } else if ( sd(na.omit(x)) == 0 || sd(na.omit(y)) == 0 ) {
        # DC signal in at least one channel
        return(t.test(c(0,0,0), c(0,0,0)))
      } else {
        # Looking good -- calculate t.test
        return(t.test(x, y, paired = FALSE))
      }

    }
    
    # NOTE:  X below ends up with a two-column matrix where each cell contains an
    # NOTE:  unnamed List of length one containing a numeric vector. Each
    # NOTE:  row of the matrix thus contains a vector of pm25_A and pm25_B
    # NOTE:  in columns 1 and 2.
    
    # Map/Reduce t.test() to nested bins in matrix rows 
    tt <- 
      apply(
        X = zoo::coredata(zagg), 
        MARGIN = 1, 
        FUN = function(x) Reduce(.ttest, x)
      )
    
    # Create and fill stats lists 
    t_score <-  p_value <- df_value <- vector("list", length(names(tt)))
    
    for ( i in names(tt) ) {
      
      val <- tt[[i]]
      ind <- which(names(tt) == i)
      
      t_score[[ind]] <- val[["statistic"]]
      p_value[[ind]] <- val[["p.value"]]
      df_value[[ind]] <- val[["parameter"]]
      
    } 
    
    # Bind unlisted stats -> 
    # Create zoo with aggregated datetime index -> 
    # Fortify to data.frame 
    tbl <- 
      zoo::fortify.zoo(
        zoo::zoo(
          cbind(
            "pm25_t" = unlist(t_score),
            "pm25_p" = unlist(p_value), 
            "pm25_df" = unlist(df_value)
          ), 
          order.by = zoo::index(zagg)
        ), 
        names = "datetime" 
      ) 
    
    return(tbl)
    
  }
  
}
