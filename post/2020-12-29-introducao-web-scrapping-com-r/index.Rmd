---
title: Introdução a Web Scrapping com R
author: ~
date: '2020-12-29'
slug: web-scrapping-introduction-with-r
categories: ["R","Web Scrapping"]
tags: ["R","Web Scrapping"]
---

Olá,
nesse post vou falar sobre Web Scraping com R.

Para iniciar vou falar sobre o projeto "SERENATA DE AMOR" [https://serenata.ai/](https://serenata.ai/)
que é um projeto aberto no qual usa data science (ciência de dados) - a mesma tecnolgia usada por gigantes como Google, Facebook e Netflix - com o objetivo de monitorar os gastos públicos e compartilhar informações de forma acessível a todos.


Até a data de hoje 29.12.2020, o projeto já reportou 8.276 ressarcimentos suspeitos à Câmara dos Deputados envolvendo 735 parlamentares diferentes e mais de R$ 3,6 mi.

Quer saber como funciona o sistema de relatórios? [Você pode ler mais neste post - clicando aqui!](https://medium.com/data-science-brigade/como-est%C3%A1-acontecendo-a-hackaton-de-den%C3%BAncias-da-opera%C3%A7%C3%A3o-serenata-de-amor-a8bd193e0c76).

Explicado o projeto Serenata, voltamos ao Web Scrapping, que neste caso
vamos utilizar o
[Jarbas](https://jarbas.serenata.ai/dashboard/chamber_of_deputies/reimbursement/) )
que é a plataforma onde ficam armazenados os documentos analisados
com o objetivo de coletar informações do site.
Com o intuito de mostrar que é possível analisar os dados
da forma que desejar para tomada de decisões,
um gráfico será gerado com os dados coletados
de alguns deputados e os valores de reembolso solicitados por eles.

Passo 1: Lendo a URL.

Para ler a página em html, será utilizado a função "read_html" do pacote *rvest*.

```{r}
library(rvest)
url <- "https://jarbas.serenata.ai/dashboard/chamber_of_deputies/reimbursement/"
jarbas_webpage <- read_html(url)
```

Passo 2: Agora, a melhor parte da biblioteca rvest é que você pode extrair os dados de html em forma de nós, o que significa que você pode selecionar imediatamente quais os nós através dos ids ou classes css e extrair o texto das tags do html. Então eu fui para o meu url e abri o "*firebug *" no navegador e percebi que os nomes dos deputados foram encapsulados na classe css "*.field-congressperson_name *", usando esta classe css que posso extrair todos os nomes dos deputados na página da web.

Existem 2 funções que usaremos aqui:

1. html_nodes: Use esta função para extrair os nós que desejamos (neste caso nós com ".field-congressperson_name" como classe css
2. html_text: Use esta função para extrair o texto entre dos nós html (neste caso, os nomes de nossos representantes)

```{r}
#Scraping  usando classe css ‘field-congressperson_name’
jarbas_names_html <-html_nodes(jarbas_webpage, '.field-congressperson_name')
jarbas_names <- html_text(jarbas_names_html)
head(jarbas_names)
```

Da mesma forma, agora farei isso para todos os outros atributos: SUBQUOTA TRANSLATED, FORNECEDOR. Cada um desses atributos tem suas próprias classes css: field-subquota_translated, field-supplier_info.

```{r}
#SUBQUOTA TRANSLATED
jarbas_subquota_html <-html_nodes(jarbas_webpage, '.field-subquota_translated')
jarbas_subquota <- html_text(jarbas_subquota_html)
head(jarbas_subquota)

#Fornecedor
jarbas_provider_html <-html_nodes(jarbas_webpage, '.field-supplier_info')
jarbas_provider <- html_text(jarbas_provider_html)
head(jarbas_provider)
```

A seguir serão mostrados o valor do reembolso, note que eles são extraídos
em tipo de variável caracter: Ex: R\$ 139,76, R\$ 40,23.
Entretanto, como desejamos manipular esses números, precisamos convertê-los para tipo de variável numérica, dessa forma será utilizado a biblioteca: "*Stringr*" mais especificamente a função: `str_extract`. Segue o script para conversão da variável.


```{r}
library(stringr)
#valores em Real
jarbas_value_html <-html_nodes(jarbas_webpage, '.field-value')
jarbas_value <- html_text(jarbas_value_html)
head(jarbas_value)
#R$ 139,76" "R$ 40,23"  "R$ 72,05"  "R$ 72,05"  "R$ 56,39"  "R$ 235,64"  
#dados extraídos na forma de caracter, vamos converter para tipo numérico
jarbas_value <- as.numeric(sub(",",".",str_extract(jarbas_value,pattern = "\\-*\\d+,\\s{0,}\\d+")))
head(jarbas_value,25)
```

Passo 3: Com essas informações disponíveis, vamos gerar um dataframe.
Para facilitar a visualização, apenas o primeiro nome de cada deputado foi selecionado.

```{r}
#Combinando todas as características obtidas
jarbas_names <- str_extract(jarbas_names,pattern = boundary("word"))
jarbas_df <- data.frame(
  Name = jarbas_names,
  Subquota = jarbas_subquota,
  Provider = jarbas_provider,
  Value = jarbas_value
  )
str(jarbas_df)
```
  
Passo 4:  Numa primeira análise, podemos utilizar gráfico entre o valor do reembolso e o nome dos deputados. Foram utilizados as 50 primeiras linhas do data.frame e uma biblioteca *ggplot2* para geração do gráfico.


```{r, fig.width=8}
library(ggplot2)

jarbas_df <- jarbas_df[1:50,]

ggplot(
  jarbas_df, aes(Value,Name,colour=Subquota)) +
  geom_point() +
  labs(title="", x ="pedidos de reembolso (R$)",
       y = "deputados",colour="SUBQUOTA TRANSLATED")
```



