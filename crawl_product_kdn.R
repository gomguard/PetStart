###########################################################################
#
#    script_name : crawl_product_kdn.R
#    author      : Gomguard
#    created     : 2020-03-08 23:05:39
#    description : From koreadognews.co.kr Crawl new product news 
#
###########################################################################


library(tidyverse)
library(RSelenium)




pjs <- wdman::phantomjs(port = 4567L)

remdr <- remoteDriver(port = 4567L, browserName = 'phantomjs')
remdr$open()


base_url <- 'http://www.koreadognews.co.kr/news/index.php?code=20170731232340_8521&d_code=20170731232429_1485&page_rows=3&page='


news_list[[1]]$getElementAttribute

res = tibble()
for (idx in 1:38) {
  print('-------')
  print(idx)
  remdr$navigate(paste0(base_url, idx))
  # remdr$screenshot(display = T)
  for (in_idx in 1:3) {
    print(in_idx)
    base_xpath <- sprintf('//*[@id="news_data"]/div[%s]', in_idx)
    # print(base_xpath)
    href <- remdr$findElements(using = 'xpath', value = paste0(base_xpath, '/div[1]/h2/a'))[[1]]$getElementAttribute(attrName = 'href') %>% unlist()
    # print('h-')
    time <- remdr$findElements(using = 'xpath', value = paste0(base_xpath, '/div[1]/div'))[[1]]$getElementText() %>% unlist()
    # print('t-')
    title <- remdr$findElements(using = 'xpath', value = paste0(base_xpath, '/div[1]/h2/a'))[[1]]$getElementText() %>% unlist()
    # print('l-')
    content <- remdr$findElements(using = 'xpath', value = paste0(base_xpath, '/div[2]/h2/a'))[[1]]$getElementText() %>% unlist()  
    # print('c-')
    res <- res %>% 
      bind_rows(tibble(href, time, title, content))
  }
  
  
  # 하단의 신제품 정보기사 란 선택
  # news_list <- remdr$findElements(using = 'class', value = 'sub01_newslist02')
  # news_list %>% 
  #   map_chr(function(.x){
  #     title <- .x$getElementText() %>% unlist()
  #     # content <- raw %>% 
  #     #   .$findElements(using = 'class', value = 'newslist_text02') %>% 
  #     #   .$getElementText()
  #   }) %>% 
  #   enframe() %>% 
  #   separate(col = value, into = c('title', 'time', 'content'), sep = '\\n')
}

res %>% 
  select(time, title, content, href) %>% 
  write_csv('./kdn_new_product_200309.csv')

res %>% 
  mutate(food = str_detect(title, '(사료|간식|푸드|건강식|맥주|피자|음료)')) %>% 
  arrange(food) %>% 
  group_by(food) %>% 
  count()
