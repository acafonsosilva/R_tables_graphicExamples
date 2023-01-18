Pretty tables
================
2023-01-18


<br />

## Example of icons inside the table

Using a test data set with binary data like the plants traits data set
from the cluster package.

- Sample 10 observations and five traits

``` r
data0 <- cluster::plantTraits %>% 
  sample_n(10) %>% 
  select(lign, leafy, suman, everalw, windgl) 
```

<br />

Could use library Icons but would prefer to use google icons
(<https://fonts.google.com/icons>) and this is not working
(<https://github.com/mitchelloharawild/icons/issues/70>). So picked the
icons on the website and use R to download them.

- Prepare table with download links and saving path to extract icons.
  Save icons with matching name with data.

``` r
dir.create(here('elements'), showWarnings = FALSE)
urls <- 'https://fonts.gstatic.com/s/i/short-term/release/materialsymbolsoutlined/'

icons <- data.frame(urls=paste0(urls, c("check_circle","cancel"),"/default/48px.svg"),
                    svgs = here('elements', paste0(c("1","0"),".svg")),
                    code = c("Present","Absent"))

walk2(icons$urls, icons$svgs, safely(~ download.file(.x , .y, mode = "wb")))
```

<br />

- Edit icons to have different colors with the package Magick, and to
  make an empty icon for missing data.

``` r
present <- image_colorize(image_read_svg(icons$svgs[1]), 100, '#93c47d')
absent <- image_colorize(image_read_svg(icons$svgs[2]), 100, '#EA9999')

image_write(present,  path = icons$svgs[1], format = "svg")

image_write(absent, path = icons$svgs[2], format = "svg")

image_write(image_colorize(present, 100, 'white'), 
            path = here('elements',"NA.svg"), format = "svg")

## show colored icons
image_append(c(present, absent))
```

<br />

- Replace the data by the icons paths.

``` r
icons <- data.frame(icons = list.files(here('elements'), full.names = TRUE, pattern = '.svg')) %>%
  mutate(value = basename(tools::file_path_sans_ext(icons)))

data <- data0 %>% 
  rownames_to_column('Species') %>% 
  pivot_longer(-Species, values_ptypes = as.character()) %>% 
  replace_na(list(value = "NA")) %>% 
  left_join(icons, by = 'value') %>% 
  select(-value) %>% 
  pivot_wider(names_from = name, values_from = icons)
```

<br />

- Use the gt package to include icons while making table.

``` r
qr <- gt(data) %>% 
  tab_header(
    title = md("Subsample of plants traits dataset")) %>% 
  opt_table_font(font = list(google_font("Mina"), default_fonts())) %>% 
  cols_label(lign = 'Woody plant', leafy = 'Leafy plant', 
             suman = 'Summer annual',everalw = 'Leaves always evergreen',
             windgl = 'Wind dispersed fruits') %>%  
  text_transform(locations = cells_body(columns = 2:ncol(data), rows = everything()),
                 fn = function(x) { map_chr(x, ~ local_image(filename = .x,
                                                             height = 24))}) %>%
  tab_source_note(
    source_note = md("**Source:** Data from plantTraits of the Cluster package.")) %>% 
  cols_align(
    align = "center",
    columns = everything()) %>%
  cols_width(everything() ~ px(70))  %>%
  tab_style(style = list(cell_text(weight = "bold")),
            locations = list(cells_body(columns = Species, 
                                        rows = everything()),
                             cells_column_labels(columns = everything()))) %>% 
  tab_options(data_row.padding = px(0),
              data_row.padding.horizontal = px(0),
              table.font.size = px(14),
              heading.align = 'center',
              table.border.top.style = "hidden",
              table.border.bottom.style = "hidden",
              table_body.hlines.style = "hidden",
              table.background.color = "#FFFFFF00")
gtsave(qr, "figures/fig1.png")
```

<img src="figures/fig1.png" width="250" />

<br />

------------------------------------------------------------------------

## Example of table with all elements as icons

Make customized images for each element in illustrator
(elementsToExport.ai). \* Name the files differently depending if these
are column names, row names or content.

<br />

- Replacing all elements as icons requires some data wrangling given the
  transforming function doesn’t work for column names

``` r
icons <- data.frame(icons = list.files(here('elements'), full.names = TRUE, 
                                       pattern = '.svg')) %>%
  mutate(columns = basename(tools::file_path_sans_ext(icons))) %>% 
  filter(str_detect(columns, "_")) %>% 
  separate(columns, into = c("column","content"), sep = "_", extra = "drop")

# prepare column header
colData <- data.frame(content = c('Species',colnames(data0))) %>% 
  left_join(filter(icons, column %in% 'header'), by = "content") %>% 
  pivot_wider(names_from = content, values_from = icons) %>% 
  select(-column)

# prepare row header
rowData <- data.frame(content = as.character(seq(1:nrow(data0)))) %>% 
  left_join(filter(icons, column %in% 'Species'), by = "content") %>% 
  rename(Species = icons) %>% 
  select(-column, -content)

# prepare content
data1 <- data0 %>% 
  mutate(row = row_number()) %>% 
  pivot_longer(cols = -row, names_to = "column", values_to = "content",
               values_ptypes = as.character()) %>% 
  replace_na(list(content = "NA")) %>% 
  left_join(select(filter(icons, column %in% 'content'),-column), 
            by = 'content') %>% 
  pivot_wider(id_cols = row, names_from = column, values_from = icons) %>% 
  select(-row)

dataIcons <- colData %>% 
  bind_rows(cbind(rowData, data1))
```

``` r
qr2 <- gt(dataIcons) %>% 
  tab_header(
    title = md("Subsample of plants traits dataset")) %>% 
  opt_table_font(font = list(google_font("Mina"), default_fonts())) %>% 
  text_transform(locations = cells_body(columns = everything(), rows = everything()),
                 fn = function(x) { map_chr(x, ~ local_image(filename = .x,
                                                             height = 50))}) %>%
  tab_source_note(
    source_note = md("**Source:** Data from plantTraits of the Cluster package.")) %>% 
  cols_align(
    align = "center",
    columns = everything()) %>%
  tab_options(data_row.padding = px(0),
              data_row.padding.horizontal = px(0),
              table.font.size = px(14),
              heading.align = 'center',
              column_labels.hidden = TRUE, ## remove header without icons paths
              table.border.top.style = "hidden",
              table.border.bottom.style = "hidden",
              table_body.hlines.style = "hidden") 
gtsave(qr2, "figures/fig2.png")
```

<img src="figures/fig2.png" width="250" />
