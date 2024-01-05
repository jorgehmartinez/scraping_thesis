
######################### Webscraping con R ################################ 
#################### Autor: Jorge Huanca Martinez  #########################

# Conceptos previos ------------------------------------------------------------

## Listas ----
apellidos <- c("guerrero","cueva","flores","carrillo","gallese")
apellidos[3]
class(apellidos)
apellidos


## Iteracion ----
for(i in apellidos){
  saludo <- paste("Hola", i)
  print(saludo)
}


df <- data.frame() # creación de un dataframe

for(i in apellidos){
  saludo <- paste("Hola", i)
  df <- rbind(df, saludo)
}



## Iteración - secuencia ----

for(decada in seq(from = 1970, to = 2010, by = 10)){
  mensaje <- paste("La década de", decada, "fue la mejor")
  print(mensaje)
}


# Web scraping -----------------------------------------------------------------

## Instalar y cargar librerías ----

#install.packages("rvest")      
#install.packages("tidyverse")  
#install.packages("openxlsx")   

library(rvest)      # Web Scraping
library(tidyverse)  # Manipular data
library(openxlsx)   # Importar y exportar archivos excel

## Guardar URL ----
url <- "https://repositorio.upch.edu.pe/handle/20.500.12866/70/recent-submissions"

## Leer HTML ----
page <- read_html(url) 

## Extracción de nodos ----
titulo <- page |> html_nodes(".artifact-title") |> html_text()
año    <- page |> html_nodes(".date")           |> html_text()
autor  <- page |> html_nodes(".author span")    |> html_text()

## Leer URL de 3 páginas ----
for (page_result in seq(from = 0, to = 40, by = 20)) {
  url <- paste0("https://repositorio.upch.edu.pe/handle/20.500.12866/20/recent-submissions?offset=", page_result) 
  print(url)
}

## Almacenar nodos en una BD ----
df <- data.frame()

for (page_result in seq(from = 0, to = 40, by = 20)) {
  
  url  <- paste0("https://repositorio.upch.edu.pe/handle/20.500.12866/70/recent-submissions?offset=", page_result)
  page <- read_html(url)
  
  titulo <- page |> html_nodes(".artifact-title") |> html_text()
  año    <- page |> html_nodes(".date")           |> html_text()
  autor  <- page |> html_nodes(".author span")    |> html_text()
  
  df <- rbind(df, data.frame(titulo, año, autor))
  
  print(paste("Pagina:", (page_result/20)+1))
}

View(df)

write.xlsx(df, "output/tesis_psicología_upch.xlsx")


# Extraer metadata -------------------------------------------------------------

# Por problemas de carga del repositorio institucional de la UPCH, 
# se optó por realizar el siguiente ejemplo con la página de la UPC

## Crear funciones para extraer metadata ----

## Extraer Tópicos ----
get_topico  <- function(x) {
  
  tesis_page <- read_html(x)
  
  tesis_topico <- tesis_page |> 
    html_nodes(".even:nth-child(22) .word-break , .odd:nth-child(21) .word-break") |>
    html_text() |> 
    paste(collapse = ",")
  
  return(tesis_topico)
}

df2 <- data.frame()

## Loop para 3 páginas ----
for (page_result in seq(from = 0, to = 40, by = 20)) {
  
  url  <- paste0("https://repositorioacademico.upc.edu.pe/handle/10757/621443/recent-submissions?offset=", page_result)
  page <- read_html(url)
  
  año <- page |> 
    html_nodes(".date") |> 
    html_text()
  
  titulo <- page |> 
    html_nodes(".list-title-clamper") |> 
    html_text()
  
  links <- page |> 
    html_nodes("#aspect_discovery_recentSubmissions_RecentSubmissionTransformer_div_recent-submissions a")  |> 
    html_attr("href") 
  
  tesis_links <- paste0("https://repositorioacademico.upc.edu.pe", links)
  
  tesis_links_full <- paste0("https://repositorioacademico.upc.edu.pe", links, "?show=full")
  
  topico <- sapply(tesis_links_full, FUN = get_topico, USE.NAMES = FALSE) 
  
  df2 <- rbind(df2, data.frame(titulo, año, topico, tesis_links)) 
  
  print(paste("Page:", (page_result/20)+1))

}

## Exportar data como archivo excel ----
write.xlsx(df2, "output/tesis_psicología_upc.xlsx")
