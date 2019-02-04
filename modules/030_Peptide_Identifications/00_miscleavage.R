init <- function() {
  
  type <- 'plot'
  box_title <- 'Miscleavage rate'
  help_text <- 'Plotting frequency of peptide miscleavages.'
  source_file <- 'evidence'
  
  .validate <- function(data, input) {
    validate(need(data()[['evidence']], paste0('Upload evidence.txt')))
  }
  
  .plotdata <- function(data, input) {
    plotdata <- data()[['evidence']][,c('Raw.file', 'Missed.cleavages', 'PEP')]
    return(plotdata)
  }
  
  .plot <- function(data, input) {
    .validate(data, input)
    plotdata <- .plotdata(data, input)
    
    ggplot(plotdata, aes(Missed.cleavages)) + 
      facet_wrap(~Raw.file, nrow = 1) + 
      geom_histogram(bins=10) + 
      coord_flip() + 
      labs(x='Missed Cleavages', y='Count') +
      theme_base(input=input)
  }
  
  return(list(
    type=type,
    box_title=box_title,
    help_text=help_text,
    source_file=source_file,
    validate_func=.validate,
    plotdata_func=.plotdata,
    plot_func=.plot,
    dynamic_width=150
  ))
}