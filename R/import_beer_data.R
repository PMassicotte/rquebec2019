if (fs::dir_exists("data/raw/beer/")) {
  fs::dir_delete("data/raw/beer/")
} 

fs::dir_create("data/raw/beer/")

df <- read_csv2("https://data.opendatasoft.com/explore/dataset/open-beer-database@public-us/download/?format=csv&timezone=America/New_York&use_labels_for_header=true", guess_max = 1e5) %>% 
  janitor::clean_names() %>% 
  drop_na(country)

names(df)

df <- df %>% 
  select(name, id, brewer, alcohol_by_volume, style:brewer, country)

df %>% 
  count(country)

df %>% 
  group_split(country) %>% 
  walk(~write_csv(., path = paste0("data/raw/beer/",unique(.$country),".csv")))
  
count(df, country)
