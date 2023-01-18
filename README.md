Pretty tables
================
2023-01-18

<style type="text/css">
body{
font: 14px "Mina", sans-serif;
}
</style>

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

![](figures/fig1.png)

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
gt(dataIcons) %>% 
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
```

<div id="rinrlqwvhc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>@import url("https://fonts.googleapis.com/css2?family=Mina:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
html {
  font-family: Mina, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#rinrlqwvhc .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: hidden;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: hidden;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#rinrlqwvhc .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rinrlqwvhc .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#rinrlqwvhc .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#rinrlqwvhc .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#rinrlqwvhc .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rinrlqwvhc .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rinrlqwvhc .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#rinrlqwvhc .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#rinrlqwvhc .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#rinrlqwvhc .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#rinrlqwvhc .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#rinrlqwvhc .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#rinrlqwvhc .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#rinrlqwvhc .gt_from_md > :first-child {
  margin-top: 0;
}

#rinrlqwvhc .gt_from_md > :last-child {
  margin-bottom: 0;
}

#rinrlqwvhc .gt_row {
  padding-top: 0px;
  padding-bottom: 0px;
  padding-left: 0px;
  padding-right: 0px;
  margin: 10px;
  border-top-style: hidden;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#rinrlqwvhc .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 0px;
  padding-right: 0px;
}

#rinrlqwvhc .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#rinrlqwvhc .gt_row_group_first td {
  border-top-width: 2px;
}

#rinrlqwvhc .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rinrlqwvhc .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#rinrlqwvhc .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#rinrlqwvhc .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rinrlqwvhc .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rinrlqwvhc .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#rinrlqwvhc .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#rinrlqwvhc .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rinrlqwvhc .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rinrlqwvhc .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rinrlqwvhc .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rinrlqwvhc .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rinrlqwvhc .gt_left {
  text-align: left;
}

#rinrlqwvhc .gt_center {
  text-align: center;
}

#rinrlqwvhc .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#rinrlqwvhc .gt_font_normal {
  font-weight: normal;
}

#rinrlqwvhc .gt_font_bold {
  font-weight: bold;
}

#rinrlqwvhc .gt_font_italic {
  font-style: italic;
}

#rinrlqwvhc .gt_super {
  font-size: 65%;
}

#rinrlqwvhc .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#rinrlqwvhc .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#rinrlqwvhc .gt_indent_1 {
  text-indent: 5px;
}

#rinrlqwvhc .gt_indent_2 {
  text-indent: 10px;
}

#rinrlqwvhc .gt_indent_3 {
  text-indent: 15px;
}

#rinrlqwvhc .gt_indent_4 {
  text-indent: 20px;
}

#rinrlqwvhc .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  <thead class="gt_header">
    <tr>
      <td colspan="6" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Subsample of plants traits dataset</td>
    </tr>
    
  </thead>
  
  <tbody class="gt_table_body">
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMi41IiB5PSIzIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjgwIiByeD0iNC41OSIvPjx0ZXh0IGNsYXNzPSJjbHMtMiIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMjEuMjUgNDguNjIpIj5TcGVjaWVzPC90ZXh0Pjwvc3ZnPg==" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDE4LjkyIDM3LjE4KSI+V29vZHk8dHNwYW4geD0iMTEuMTIiIHk9IjI0Ij5wbGFudDwvdHNwYW4+PC90ZXh0Pjwvc3ZnPg==" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDI2LjkgMzcuMTkpIj5MZWFmeTx0c3BhbiB4PSIyLjk0IiB5PSIyNCI+cGxhbnQ8L3RzcGFuPjwvdGV4dD48L3N2Zz4=" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDExLjc5IDM5Ljc1KSI+U3VtbWVyPHRzcGFuIHg9IjkuOTciIHk9IjI0Ij5hbm51YWw8L3RzcGFuPjwvdGV4dD48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjIycHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDIzLjAzIDI1LjA4KSI+TGVhdmVzPHRzcGFuIHg9Ii0wLjkxIiB5PSIyMyI+YWx3YXlzPC90c3Bhbj48dHNwYW4geD0iLTE1LjcxIiB5PSI0NiI+ZXZlcmdyZWVuPC90c3Bhbj48L3RleHQ+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjIycHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDMyLjUxIDI4LjU0KSI+V2luZDx0c3BhbiB4PSItMjIuNTgiIHk9IjIzIj5kaXNwZXJzZWQ8L3RzcGFuPjx0c3BhbiB4PSItMS43NyIgeT0iNDYiPmZydWl0czwvdHNwYW4+PC90ZXh0Pjwvc3ZnPg==" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTEsLmNscy0ye2ZpbGw6I2FkYWM5Zjt9LmNscy0ye2ZvbnQtc2l6ZToyM3B4O2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxwYXRoIGNsYXNzPSJjbHMtMSIgZD0iTTExNy4zNSwzSDcuNjVBNC44OSw0Ljg5LDAsMCwwLDIuNSw3LjU5Vjc4LjQxQTQuODksNC44OSwwLDAsMCw3LjY1LDgzaDEwOS43YTQuODksNC44OSwwLDAsMCw1LjE1LTQuNTlWNy41OUE0Ljg5LDQuODksMCwwLDAsMTE3LjM1LDNaTTExOCw3NC40MUE0Ljg5LDQuODksMCwwLDEsMTEyLjg3LDc5SDEyLjEzQTQuODksNC44OSwwLDAsMSw3LDc0LjQxVjExLjU5QTQuODksNC44OSwwLDAsMSwxMi4xMyw3SDExMi44N0E0Ljg5LDQuODksMCwwLDEsMTE4LDExLjU5WiIvPjx0ZXh0IGNsYXNzPSJjbHMtMiIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTUuMjIgNDcuOTIpIj5TcGVjaWVzIDE8L3RleHQ+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNDkgNDcuOTYpIj5TcGVjaWVzIDI8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNzQgNDcuOTIpIj5TcGVjaWVzIDM8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTEuODggNDcuOTIpIj5TcGVjaWVzIDQ8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNDYgNDcuOTIpIj5TcGVjaWVzIDU8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZTllOGU0O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PC9zdmc+" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMzMgNDcuOTIpIj5TcGVjaWVzIDY8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZTllOGU0O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PC9zdmc+" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNzIgNDcuOTIpIj5TcGVjaWVzIDc8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMjggNDcuOTIpIj5TcGVjaWVzIDg8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMzcgNDcuOTIpIj5TcGVjaWVzIDk8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td headers="Species" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoNy45IDQ3LjkyKSI+U3BlY2llcyAxMDwvdGV4dD48cGF0aCBjbGFzcz0iY2xzLTIiIGQ9Ik0xMTcuMzUsM0g3LjY1QTQuODksNC44OSwwLDAsMCwyLjUsNy41OVY3OC40MUE0Ljg5LDQuODksMCwwLDAsNy42NSw4M2gxMDkuN2E0Ljg5LDQuODksMCwwLDAsNS4xNS00LjU5VjcuNTlBNC44OSw0Ljg5LDAsMCwwLDExNy4zNSwzWk0xMTgsNzQuNDFBNC44OSw0Ljg5LDAsMCwxLDExMi44Nyw3OUgxMi4xM0E0Ljg5LDQuODksMCwwLDEsNyw3NC40MVYxMS41OUE0Ljg5LDQuODksMCwwLDEsMTIuMTMsN0gxMTIuODdBNC44OSw0Ljg5LDAsMCwxLDExOCwxMS41OVoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="lign" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="leafy" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="suman" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="everalw" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td headers="windgl" class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
  </tbody>
  <tfoot class="gt_sourcenotes">
    <tr>
      <td class="gt_sourcenote" colspan="6"><strong>Source:</strong> Data from plantTraits of the Cluster package.</td>
    </tr>
  </tfoot>
  
</table>
</div>
