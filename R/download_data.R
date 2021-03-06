#' Download Orcamento
#'
#' @family Orcamento Publico
#'
#' @param year \code{integer} between 2014 and 2019
#' @param ... additional parameters
#'
#' @examples
#'
#' (x <- download_orcamento(year = 2014))
#' (x <- download_orcamento(year = 2014:2015))
#'
#' \dontrun{
#'  (x <- download_orcamento(year = "2014"))
#'  (x <- download_orcamento(year = 2014, month = 2))
#' }
#'
#' @importFrom data.table ":="
#'
#' @return \code{data.frame}
#' @export
download_orcamento <- function(year = NULL, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2014:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be a integer value between 2014 and 2018.')

  temp_dir <- tempdir()
  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/orcamento-despesa/%d')

  lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
         file.remove) %>% invisible()

  for(i in year) {
    file_name <- paste0(sprintf('orcamento_%d', i), '.zip')
    dest <- file.path( temp_dir, file_name)
    file.create(dest)
    utils::download.file(url = sprintf(link, i), destfile = dest, quiet = T, mode = 'wb')
    # closeAllConnections()
    if(.Platform$OS.type == "windows") {
      utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
    } else {
      utils::unzip(zipfile = dest, exdir = temp_dir)
    }
  }

  out <- lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
                function(x) {
                  aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                            encoding = 'Latin-1', stringsAsFactors = F))
                  names(aux) <- fix_name(names(aux))
                  char_fct <- which(sapply(aux, is.character))
                  aux[, c(char_fct) := lapply(.SD, function(x) {
                    iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                  }), .SDcols = char_fct]
                  aux
                })
  out <- data.table::rbindlist(out)

  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}

#' Download Transferencia
#'
#' @family Despesas Publicas
#'
#' @param year \code{integer} between 2013 and 2019
#' @param month \code{integer} between 1 and 12
#' @param ... additional parameters
#'
#' @examples
#'
#' (x <- download_transf(year = 2014, month = 1))
#' (x <- download_transf(year = 2014:2015, month = 1))
#' (x <- download_transf(year = 2015, month = 1:2))
#'
#' \dontrun{
#'  (x <- download_transf(year = "2014", month = 2))
#'  (x <- download_transf(year = 2014))
#' }
#'
#' @return \code{data.frame}
#' @export
download_transf <- function(year = NULL, month = NULL, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2013:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be integer between 2013 and 2018.')

  if(any(!is.numeric(month)) | any(!month %in% 1:12))
    stop('Month must be integer between 1 and 12.')

  for(i in seq_along(month)) {
    if(as.integer(month[i]) < 10) {
      month[i] <- paste0('0', month[i])
    }
  }

  temp_dir <- tempdir()

  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/transferencias/%d%s')

  invisible(
    lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
           file.remove)
  )

  for(i in year) {
    for(j in month) {
      file_name <- paste0(sprintf('transferencias_%d%s', i, j), '.zip')
      dest <- file.path( temp_dir, file_name)
      file.create(dest)
      utils::download.file(url = sprintf(link, i, j), destfile = dest, quiet = T, mode = 'wb')
      # closeAllConnections()
      if(.Platform$OS.type == "windows") {
        utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
      } else {
        utils::unzip(zipfile = dest, exdir = temp_dir)
      }
    }
  }

  out <- lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
                function(x) {
                  aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                            encoding = 'Latin-1', stringsAsFactors = F))
                  names(aux) <- fix_name(names(aux))
                  char_fct <- which(sapply(aux, is.character))
                  aux[, c(char_fct) := lapply(.SD, function(x) {
                    iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                  }), .SDcols = char_fct]
                  aux
                })
  out <- data.table::rbindlist(out)

  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}

#' Download Execucao de Despesas
#'
#' @family Despesas Publicas
#'
#' @param year \code{integer} between 2013 and 2019
#' @param month \code{integer} between 1 and 12
#' @param ... additional parameters
#'
#' @examples
#'
#' (x <- download_exec_desp(year = 2014, month = 1))
#' (x <- download_exec_desp(year = 2014:2015, month = 1))
#' (x <- download_exec_desp(year = 2015, month = 1:2))
#'
#' \dontrun{
#'  (x <- download_exec_desp(year = "2014", month = 2))
#'  (x <- download_exec_desp(year = 2014))
#' }
#'
#' @return \code{data.frame}
#' @export
download_exec_desp <- function(year = NULL, month = NULL, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2014:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be integer between 2014 and 2018.')

  if(any(!is.numeric(month)) | any(!month %in% 1:12))
    stop('Month must be integer between 1 and 12.')

  for(i in seq_along(month)) {
    if(as.integer(month[i]) < 10) {
      month[i] <- paste0('0', month[i])
    }
  }

  temp_dir <- tempdir()

  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/despesas-execucao/%d%s')

  invisible(
    lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
           file.remove)
  )

  for(i in year) {
    for(j in month) {
      file_name <- paste0(sprintf('transferencias_%d%s', i, j), '.zip')
      dest <- file.path( temp_dir, file_name)
      file.create(dest)
      utils::download.file(url = sprintf(link, i, j), destfile = dest, quiet = T, mode = 'wb')
      # closeAllConnections()
      if(.Platform$OS.type == "windows") {
        utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
      } else {
        utils::unzip(zipfile = dest, exdir = temp_dir)
      }
    }
  }

  out <- lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
                function(x) {
                  aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                            encoding = 'Latin-1', stringsAsFactors = F))
                  names(aux) <- fix_name(names(aux))
                  char_fct <- which(sapply(aux, is.character))
                  aux[, c(char_fct) := lapply(.SD, function(x) {
                    iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                  }), .SDcols = char_fct]
                  aux
                })
  out <- data.table::rbindlist(out)

  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}

#' Download Cartoes de Pagamentos
#'
#' @family Cartao de Pagamento
#'
#' @param year \code{integer} between 2013 and 2019
#' @param month \code{integer} between 1 and 12
#' @param type must be 'cpgf' (cartao de pagamentos do governo federal),
#' 'cpcc' (cartao de pagamentos do governo federal - compras centralizadas)
#' or 'cpdc' (cartao de pagamentos da defesa civil)
#' @param ... additional parameters
#'
#' @examples
#'
#' (x <- download_cp(year = 2014, month = 1, type = 'cpgf'))
#' (x <- download_cp(year = 2015, month = 1, type = 'cpcc'))
#' (x <- download_cp(year = 2015, month = 1:2, , type = 'cpdc'))
#'
#' \dontrun{
#'  (x <- download_cp(year = "2014", month = 2, type = 'cpdc'))
#'  (x <- download_cp(year = 2014, type = 'cpdc'))
#'  (x <- download_cp(year = 2014, month = 3, type = c('cpcc', 'cpdc')))
#'  (x <- download_cp(year = 2014, month = 3))
#' }
#'
#'
#' @return \code{data.frame}
#' @export
download_cp <- function(year = NULL, month = NULL, type = NULL, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2014:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be integer between 2014 and 2018.')

  if(any(!is.numeric(month)) | any(!month %in% 1:12))
    stop('Month must be integer between 1 and 12.')

  if(length(type) > 1)
    stop('You must provide just one type.')

  if(! type %in% c('cpgf', 'cpcc', 'cpdc'))
    stop('Type must be cpgf, cpcc or cpdc.')

  for(i in seq_along(month)) {
    if(as.integer(month[i]) < 10) {
      month[i] <- paste0('0', month[i])
    }
  }

  temp_dir <- tempdir()

  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/%s/%d%s')

  lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
         file.remove) %>% invisible()

  for(i in year) {
    for(j in month) {
      file_name <- paste0(sprintf('%s_%d%s', type, i, j), '.zip')
      dest <- file.path( temp_dir, file_name)
      file.create(dest)
      utils::download.file(url = sprintf(link, type, i, j), destfile = dest, quiet = T, mode = 'wb')
      # closeAllConnections()
      if(.Platform$OS.type == "windows") {
        utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
      } else {
        utils::unzip(zipfile = dest, exdir = temp_dir)
      }
    }
  }

  out <- lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
                function(x) {
                  aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                            encoding = 'Latin-1', stringsAsFactors = F))
                  names(aux) <- fix_name(names(aux))
                  char_fct <- which(sapply(aux, is.character))
                  aux[, c(char_fct) := lapply(.SD, function(x) {
                    iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                  }), .SDcols = char_fct]
                  aux
                })
  out <- data.table::rbindlist(out)

  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}

#' Download Receitas
#'
#' @family Receitas Publicas
#'
#' @param year \code{integer} between 2013 and 2019
#' @param ... additional parameters
#'
#' @examples
#'
#' (x <- download_receitas(year = 2014))
#' (x <- download_receitas(year = 2014:2015))
#'
#' \dontrun{
#'  (x <- download_receitas(year = "2014"))
#'  (x <- download_receitas(year = 2014, month = 2))
#' }
#'
#' @return \code{data.frame}
#' @export
download_receitas <- function(year = NULL, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2013:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be integer between 2013 and 2018.')

  temp_dir <- tempdir()

  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/receitas/%d')

  invisible(
    lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
           file.remove)
  )

  for(i in year) {
    file_name <- paste0(sprintf('receitas_%d', i), '.zip')
    dest <- file.path( temp_dir, file_name)
    file.create(dest)
    utils::download.file(url = sprintf(link, i), destfile = dest, quiet = T, mode = 'wb')
    # closeAllConnections()
    if(.Platform$OS.type == "windows") {
      utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
    } else {
      utils::unzip(zipfile = dest, exdir = temp_dir)
    }
  }

  out <- lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
                function(x) {
                  aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                            encoding = 'Latin-1', stringsAsFactors = F))
                  names(aux) <- fix_name(names(aux))
                  char_fct <- which(sapply(aux, is.character))
                  aux[, c(char_fct) := lapply(.SD, function(x) {
                    iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                  }), .SDcols = char_fct]
                  aux
                })
  out <- data.table::rbindlist(out)

  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}

#' Download Viagens
#'
#' @family Viagens
#'
#' @param year \code{integer} between 2013 and 2019
#' @param interactive a \code{boolean}. If \code{TRUE}, then
#' \code{file} will be ignored.
#' @param file Which file do you want to access? The options are:
#' 1 for Pagamento, 2 for Passagem, 3 for Trecho, 4 for Viagem or
#' 5 for a merged file using all these information. This parameter
#' will only be used if \code{interactive = FALSE}.
#' @param ... additional parameters
#'
#' @examples
#'
#' \dontrun{
#'  (x <- download_viagens(year = 2018))
#'  (x <- download_viagens(year = 2017:2018))
#'
#'  (x <- download_viagens(year = 2014, interactive = F, file = 3))
#' }
#'
#' @return \code{data.table}
#' @export
download_viagens <- function(year = NULL, interactive = TRUE, file = 5, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2013:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be a integer value between 2013 and 2018.')

  temp_dir <- tempdir()
  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/viagens/%d')

  invisible(
    lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
           file.remove)
  )

  if(interactive) {
    cat('\n Which file do you want to load? \n')
    cat(' Options: \n')
    cat('\t 1. Pagamento; \n')
    cat('\t 2. Passagem; \n')
    cat('\t 3. Trecho; \n')
    cat('\t 4. Viagem; \n')
    cat('\t 5. All - Merged File.; \n')
    user_def <- as.numeric(readline(prompt = 'Type the number corresponding to the desired option and press enter: '))
  } else {
    user_def <- file
  }

  stopifnot(user_def %in% 1:5)

  for(i in seq_along(year)) {
    file_name <- paste0(sprintf('viagens_%d', year[i]), '.zip')
    dest <- file.path(temp_dir, file_name)
    file.create(dest)
    cat('Trying to download files from year ', year[i], '. \n', sep = '')
    utils::download.file(url = sprintf(link, year[i]), destfile = dest, quiet = T, mode = 'wb')
    if(user_def == 5) {
      cat('\n Warning: This functionality is under development. \n')
      utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
      to_wrt <- lapply(list.files(path = temp_dir, full.names = T, pattern = sprintf('[%d]*.csv$', i)),
                       function(x) {
                         aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                                   encoding = 'Latin-1', stringsAsFactors = F))
                         names(aux) <- fix_name(names(aux))
                         char_fct <- which(sapply(aux, is.character))
                         aux[, c(char_fct) := lapply(.SD, function(x) {
                           iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                         }), .SDcols = char_fct]
                         aux
                       })
      to_wrt <- merge_viagens(to_wrt)
      data.table::fwrite(x = to_wrt, file = file.path(temp_dir, paste0(year, '_merged.csv')))
    } else {
      file_names <- utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal', list = T)
      utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal', files = file_names[user_def, 1])
    }
  }

  if(user_def == 5) {
    out <- lapply(list.files(path = temp_dir, pattern = '.*merge.*csv$', full.names = T),
                  function(x) {
                    suppressWarnings(data.table::fread(x))
                  })
  } else {
    out <- lapply(list.files(path = temp_dir, pattern = 'csv$', full.names = T),
                  function(x) {
                    aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                              encoding = 'Latin-1', stringsAsFactors = F))
                    names(aux) <- fix_name(names(aux))
                    char_fct <- which(sapply(aux, is.character))
                    aux[, c(char_fct) := lapply(.SD, function(x) {
                      iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                    }), .SDcols = char_fct]
                    aux
                  })
  }

  out <- data.table::rbindlist(out)
  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}

#' Download Compras
#'
#' @description This functions is not ready for use.
#'
#' @param year \code{integer} between 2014 and 2019
#' @param month \code{integer} between 1 and 12
#' @param interactive a \code{boolean}. If \code{TRUE}, then
#' \code{file} will be ignored.
#' @param file \code{numeric} Which file do you want to access? The options are:
#' 1 for Apostilamento, 2 for Compras, 3 for Item, 4 for Termo Aditivo or
#' 5 for a merged file using all these information. This parameter
#' will be used only if \code{interactive = FALSE}.
#' @param ... additional parameters
#'
#' @return \code{data.frame}
#' @export
download_compras <- function(year        = NULL,
                             month       = NULL,
                             interactive = FALSE,
                             file        = NULL, ...) {
  if(any(!is.numeric(year)) | any(!year %in% 2014:as.numeric(format(Sys.Date(), '%Y'))))
    stop('Year must be integer between 2014 and 2018.')

  if(any(!is.numeric(month)) | any(!month %in% 1:12))
    stop('Month must be integer between 1 and 12.')

  month <- formatC(x = month, width = 2, flag = '0')

  temp_dir <- tempdir()
  link <- ('http://www.portaltransparencia.gov.br/download-de-dados/compras/%d%s')

  unlink(list.files(path       = temp_dir,
                    pattern    = '.csv$',
                    full.names = T))

  if(interactive) {
    cat('\n Which file do you want to load? \n')
    cat(' Options: \n')
    cat('\t 1. Apostilamento; \n')
    cat('\t 2. Compras; \n')
    cat('\t 3. Item; \n')
    cat('\t 4. Termo Aditivo; \n')
    cat('\t 5. All - Merged File.; \n')
    user_def <- as.numeric(readline(prompt = 'Type the number corresponding to the desired option and press enter: '))
  } else {
    if(is.null(file) | file < 1 | file > 5) {
      stop('add a proper "file" value')
    }
    if(file == 4) {
      stop('apostilamento not working')
    }
    user_def <- file
  }

  for(i in year) {
    for(j in month) {
      file_name <- paste0(sprintf('compras_%d%s', i, j), '.zip')
      dest      <- paste(temp_dir, file_name, sep = '/')
      file.create(dest)
      utils::download.file(url = sprintf(link, i, j), destfile = dest, quiet = T, method = 'auto')

      ls_files <- utils::unzip(zipfile = dest, exdir = temp_dir, list = T)[, 1]
      if(user_def == 5) {
        cat('\n Warning: This functionality is under development. \n')
        utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal')
        to_wrt <- lapply(list.files(path = temp_dir, full.names = T, pattern = sprintf('^%d%d.*csv$', i, j)),
                         function(x) {
                           aux <- suppressWarnings(data.table::fread(x, dec = ',', sep = ';',
                                                                     encoding = 'Latin-1', stringsAsFactors = F))
                           names(aux) <- fix_name(names(aux))
                           char_fct <- which(sapply(aux, is.character))
                           if(length(char_fct) > 0) {
                             aux[, c(char_fct) := lapply(.SD, function(x) {
                               iconv(x, from = 'LATIN1', to = 'ASCII//TRANSLIT')
                             }), .SDcols = char_fct]
                           }
                           data.table::setkey(x = aux, 'numero_contrato',
                                              'codigo_orgao', 'nome_orgao',
                                              'codigo_ug', 'nome_ug')
                           aux
                         })

        to_wrt <- merge_compras(to_wrt)
        data.table::fwrite(x = to_wrt, file = file.path(temp_dir, paste0(i, j,'_merged.csv')))
      } else {
        file_names <- utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal', list = T)
        utils::unzip(zipfile = dest, exdir = temp_dir, unzip = 'internal', files = file_names[user_def, 1])
      }
    }
  }

  if(user_def == 5) {
    out <- lapply(list.files(path = temp_dir, pattern = '.*merge.*csv$', full.names = T),
                  function(x) {
                    suppressWarnings(data.table::fread(x))
                  })
  } else {
    out <- lapply(list.files(path = temp_dir, pattern = '.csv$', full.names = T),
                  function(x) {
                    aux <- readLines(x)
                    aux <- iconv(aux, from = 'ISO-8859-1', to = 'ASCII//TRANSLIT')
                    output <- suppressWarnings(data.table::fread(text = aux, dec = ',', sep = ';'))
                    return(output)
                  })
  }
  out <- data.table::rbindlist(out)

  unlink(list.files(temp_dir, full.names = T), recursive = T)

  return(out)
}
