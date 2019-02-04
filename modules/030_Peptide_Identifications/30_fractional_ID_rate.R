init <- function() {
  
  type <- 'plot'
  box_title <- 'Fractional ID Rate'
  help_text <- 'Fractional rate of confident PSMs and PSMs from all MS2 scan events'
  source_file <- 'evidence, msmsScans'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
    validate(need(data()[['msmsScans']], paste0('Upload msmsScans.txt')))
  }
  
  .plotdata <- function(data, input) {
    
    # MS2 Scans and PSMs
    a <- data()[['msmsScans']] %>%
      dplyr::select('Raw.file', 'Sequence') %>%
      group_by(Raw.file) %>%
      summarise(scans=n(),
                psms=sum(as.character(Sequence) != ' ', na.rm=T)) %>%
      arrange(Raw.file)
    
    # IDs at 5e-2 and 1e-2 PEP
    b <- data()[['evidence']] %>%
      dplyr::select('Raw.file', 'Sequence', 'PEP') %>%
      group_by(Raw.file) %>%
      summarise(ids_0p05=sum(PEP < 0.05),
                ids_0p01=sum(PEP < 0.01)) %>%
      arrange(Raw.file)
    
    plotdata <- cbind(a, b[,-1]) %>%
      # get fractional rates, i.e., fraction of MSMS scans
      mutate(psms = psms / scans,
             ids_0p05 = ids_0p05 / scans,
             ids_0p01 = ids_0p01 / scans) %>%
      # gather = dplyr equiv. of reshape2::melt
      tidyr::gather(key, value, -Raw.file) %>%
      # remove msms scans
      filter(key != 'scans') %>%
      # rename levels
      mutate(key=factor(key, labels=c('IDs @ PEP < 0.01', 'IDs @ PEP < 0.05', 'PSMs')))
    
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Raw.file, value, fill=key)) +
      geom_bar(stat='identity', position='identity') +
      labs(x='Experiment', y='Fraction', fill='Category') +
      theme_base(input=input, show_legend=T) +
      # keep the legend
      theme(legend.position='right',
            legend.key=element_rect(fill='white'))
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=100
  ))
}
