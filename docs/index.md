---
title: "Pretty tables"
date: "2022-11-23"
output: html_document
runtime: shiny
---



<style type="text/css">
body{
font: 14px "Mina", sans-serif;
}
</style>

<br />

## Example of icons inside the table

Using a test data set with binary data like the plants traits data set from the cluster package.

* Sample 10 observations and five traits


```r
data0 <- cluster::plantTraits %>% 
  sample_n(10) %>% 
  select(lign, leafy, suman, everalw, windgl) 

### make test csv file to be used later with shinny app
tempdata0 <- data0 %>% 
  add_column("Species" = as.character(seq(1:nrow(data0))), .before = "lign")

write_csv(tempdata0, here("plantTraitsSubset.csv"))
```

<br />

Could use library Icons but would prefer to use google icons (https://fonts.google.com/icons) and this is not working (https://github.com/mitchelloharawild/icons/issues/70). So picked the icons on the website and use R to download them.

* Prepare table with download links and saving path to extract icons. Save icons with matching name with data.


```r
dir.create(here('elements'), showWarnings = FALSE)
urls <- 'https://fonts.gstatic.com/s/i/short-term/release/materialsymbolsoutlined/'

icons <- data.frame(urls=paste0(urls, c("check_circle","cancel"),"/default/48px.svg"),
                    svgs = here('elements', paste0(c("1","0"),".svg")),
                    code = c("Present","Absent"))

walk2(icons$urls, icons$svgs, safely(~ download.file(.x , .y, mode = "wb")))
```
<br />

* Edit icons to have different colors with the package Magick, and to make an empty icon for missing data.


```r
present <- image_colorize(image_read_svg(icons$svgs[1]), 100, '#93c47d')
absent <- image_colorize(image_read_svg(icons$svgs[2]), 100, '#EA9999')

image_write(present,  path = icons$svgs[1], format = "svg")

image_write(absent, path = icons$svgs[2], format = "svg")

image_write(image_colorize(present, 100, 'white'), 
            path = here('elements',"NA.svg"), format = "svg")

## show colored icons
image_append(c(present, absent))
```

<img src="figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

<br />

* Replace the data by the icons paths.


```r
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

* Use the gt package to include icons while making table.


```r
gt(data) %>% 
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
```

<!--html_preserve--><div id="rihefhvvlu" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>@import url("https://fonts.googleapis.com/css2?family=Mina:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
html {
  font-family: Mina, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#rihefhvvlu .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  background-color: rgba(255, 255, 255, 0);
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

#rihefhvvlu .gt_heading {
  background-color: rgba(255, 255, 255, 0);
  text-align: center;
  border-bottom-color: rgba(255, 255, 255, 0);
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rihefhvvlu .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: rgba(255, 255, 255, 0);
  border-bottom-width: 0;
}

#rihefhvvlu .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: rgba(255, 255, 255, 0);
  border-top-width: 0;
}

#rihefhvvlu .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rihefhvvlu .gt_col_headings {
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

#rihefhvvlu .gt_col_heading {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
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

#rihefhvvlu .gt_column_spanner_outer {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#rihefhvvlu .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#rihefhvvlu .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#rihefhvvlu .gt_column_spanner {
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

#rihefhvvlu .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
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
}

#rihefhvvlu .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
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

#rihefhvvlu .gt_from_md > :first-child {
  margin-top: 0;
}

#rihefhvvlu .gt_from_md > :last-child {
  margin-bottom: 0;
}

#rihefhvvlu .gt_row {
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

#rihefhvvlu .gt_stub {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 0px;
  padding-right: 0px;
}

#rihefhvvlu .gt_stub_row_group {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
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

#rihefhvvlu .gt_row_group_first td {
  border-top-width: 2px;
}

#rihefhvvlu .gt_summary_row {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rihefhvvlu .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#rihefhvvlu .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#rihefhvvlu .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rihefhvvlu .gt_grand_summary_row {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rihefhvvlu .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#rihefhvvlu .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#rihefhvvlu .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rihefhvvlu .gt_footnotes {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
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

#rihefhvvlu .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rihefhvvlu .gt_sourcenotes {
  color: #333333;
  background-color: rgba(255, 255, 255, 0);
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

#rihefhvvlu .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rihefhvvlu .gt_left {
  text-align: left;
}

#rihefhvvlu .gt_center {
  text-align: center;
}

#rihefhvvlu .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#rihefhvvlu .gt_font_normal {
  font-weight: normal;
}

#rihefhvvlu .gt_font_bold {
  font-weight: bold;
}

#rihefhvvlu .gt_font_italic {
  font-style: italic;
}

#rihefhvvlu .gt_super {
  font-size: 65%;
}

#rihefhvvlu .gt_two_val_uncert {
  display: inline-block;
  line-height: 1em;
  text-align: right;
  font-size: 60%;
  vertical-align: -0.25em;
  margin-left: 0.1em;
}

#rihefhvvlu .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#rihefhvvlu .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#rihefhvvlu .gt_slash_mark {
  font-size: 0.7em;
  line-height: 0.7em;
  vertical-align: 0.15em;
}

#rihefhvvlu .gt_fraction_numerator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: 0.45em;
}

#rihefhvvlu .gt_fraction_denominator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: -0.05em;
}
</style>
<table class="gt_table" style="table-layout: fixed;; width: 0px">
  <colgroup>
    <col style="width:70px;"/>
    <col style="width:70px;"/>
    <col style="width:70px;"/>
    <col style="width:70px;"/>
    <col style="width:70px;"/>
    <col style="width:70px;"/>
  </colgroup>
  <thead class="gt_header">
    <tr>
      <th colspan="6" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Subsample of plants traits dataset</th>
    </tr>
    
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;">Species</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;">Woody plant</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;">Leafy plant</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;">Summer annual</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;">Leaves always evergreen</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" style="font-weight: bold;">Wind dispersed fruits</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Rubpe</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Cirlu</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Prusi</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Hedhe</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Fagsy</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Rumco</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Leuvu</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Melof</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Rosar</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBUUFBQUQ5Q3pFTUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUFBbUpMUjBRQS80ZVB6TDhBQUFNNlNVUkIKVkZqRDNaalpiNHhSR0lkL001MVJMUWs2R2lXRVNNU1ZRVFNxVlV2NUJ6UkJpTCtDRzlJYnBKYVNWQ3BhUzVBUUxseFFXeG8zOUVwRQpKSlkybGxnU3JkaTNHMHRiTVgxY09QTjF2cDV2SmIzZ25LczU1MzJmM3pudmVjL3lUUUtOYkVtT01QOC9FRWhGR2tTVjZsU3AyWnFzCnNaSys2cTBlNjQ0NmRWTzVVRytDYXdVN2VJRmZlY1VlcGdZVGdqb24wRUlmWVdXQWcyVCtSR0ExN3h6SU0vYXpsaXhscEVoUlJwWTEKdFBERTZmL0lobmdDS2RxTTZ5RG5xU1hoNDE3TldYTEc4aWpwcUFJbFhEWk8zU3dPV1NOUnhWMWpmWVV4VVFUU0R2NHdvMFB4UWhUVAo2a2lrd3dVT205QnNqZ1RQMTQwTUFuQWtUR0M5R1VzOHZCQ2JqT2U2SUlHSmZBVGdVR3k4a0VtTUQrNmtkWnNjQXFBcll1enR0YmdIClFKdWZ3RFFHZ0J6VmY0VC9uYlk1b0w5d2R4ZDI3d0dnUFNhMHpKVTU3UUEwZVFta2VBMUFUU3g4T2QxY1lKVHp1d2FBbHhUWkFyVUEKUFBYZHRkNzRMZ0E2S0RZdENaNEJESVY1NkQ2b2t5UjFLUG9kV3E1cnlrcVN2ampITnJvaVNWcGhYemdMSkVrM1l1Q3ZhbzRrNmJRMgo2S2ZUZnIyQTVyb1BIZ0tRalJrY09EVVViNFNZQzhCOWV3MCtBekJoMk1hYkhoTXZNdVlBdHdSK0FMaFNycHd1ZXBrWmdEOUR5dW9kClphNGhTMkFBb0NEaFNnM21PVE9HemNwLzlJRUNuNndRYlRPZ1Fva3dmRUNJSGdBdzEyVzgzY0R5Z1FvT3p1ODYzMXhWbGtDNzEyRkwKWThFc3drY3Y4Z2YrT1Z1Z0FZQURsc05PUjZJN0FqNS9hRyt4QlJZWmpIMVU3SFk5VTRMeENYb0FXR2dMSk0wRGE1bUhXMU5FdkZnSwpRQTlKVzBEc0FPQ3lwK1BlU0hpWkIwUGpVRXRoNXlTK0ExRG42Ym9ySUhQeWRRbURRQjlUdkFWRUN3QVBLZlYwVDRiZ1M4MTUxbHpZCjZqWVp6MXNBVG9TZ3ZPdHhBTjR3emw5QTFKdjN6ZGJZK0FhVEJ2WHVkdHV3eFJqR2syZ3dBOXMvdk1jMkxUSjdHazc2ck1Yd1dzSXgKNDNIUlRnTXZoMkpINHBGUFJya3o1NzZ4dmtTSjNlL3RWTVErTStWQk9sanU4eEJJc0lSTHhnNWF2WlBZZjJTcmVPUHMzeDdhV005OApNcVJKazJFZTYyamx1ZFAvbnJWK25LREpqNlBaYkwyZzBzOEJ5dndwWVJHdW9KRmVYL2hMbXNJK0FoTVJua0ZKVldxbEtqVkxVelZHCjBqZTkwbFBkVnFkdWhYL0dSaEg0cS9Mdi81VXc0Z0svQUhEZ1lxWGZtRlhIQUFBQUFFbEZUa1N1UW1DQyIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
    <tr><td class="gt_row gt_center" style="font-weight: bold;">Sonol</td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJkMUJNVkVYcW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucQptWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xCm1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnFtWm5xbVpucW1abnEKbVpucW1abnFtWm5xbVpucW1abnFtWm4vLy85b2RUcm1BQUFBZTNSU1RsTUFBamw2cnRYdSt0YXZmVHNER0lUaTVZa2NFWkQzK1pZVApWT25ja1ZZdUVnUlYydXhibGY0OEFhejltd1VKczlJM3o3Y0xtQWdIbEhkeG1WbHlXQlNYNjlGYTBCMzRpT1k2NU51Y2szdXdWeS9VCkJ1MHcwNjJTZURqZjREWS9Qb01YOWtFOUdncU5FT2lnbmVjUFVYK2hzZGV5anJWQVVESHE0WG4yOUs4UUFBQUFBV0pMUjBSODBiWWcKWHdBQUFrbEpSRUZVU01mZFZldGZFa0VVblYzV0JSVXRFNGxTWU10QVF0QWVCSldaUldtYVdscHFKWllwWVErMWg3MDcvM3gzMWhobgpaM2ZnMThlNm4rYWVPV2Yydm5hR3NmL1JERE5rZGRqaHNCM3A3T3FPdHFYMzlCNkRaTWY3VHJTazk4Y0dvRmo4WkVMUFAzV2FVd2FICmtxbTA0NlJUWjJKbnVUOThUa04zTXJTYjdSekpTWmg1UGsvZ2FDR0lYeHlqcmZGdUZiNXdrZUJMbC8zOEF1ZVhydmczeWhXdThIK2oKUk9GY0RZNzFXaGE0cm9JVGRJeUd6OWdOMnB6MFFqZUhnU2w5K2FnY3Q3elZuUUp1dS9IbnFuS1JtbTc1RHBDUjhidHg1RTJYVUVKSgpVZ2pYekdOYTdua2ZZTG1MS2k5VlR1SURWWGRwQVROU3krNEJzMGVVcGtKMlpvRzVvMGtjQWU3N1NWN3hJR0FLUVJjUUUySHdQczBiCnRPQ1RNbW8wOFFWZ1VRZ2VBRWs1VVg2dzUzeXloODAwdVVXQUZGTVVDcDh0QWN2Q3NZRitwaWdVUGt2UW5Bc25ESGlHeTgxRGlwL2IKSS9xWDlBS2VyNXU1UnZENGIwUHFBSmJhSmIwQ3JBckhrcWRYVTFhYS96WGhoSUFubnZoNXZxS0RoMGJ3VXlGNEJxeTNHNDBhc0NFRQpCbDFlejVtZkpEa3ZnSnBVdFY1Z3pGMW94NXV1aUUycFppKzNnTzAvTFpQN0pkeDZGZ092NUxiRWdFakRwUVQrb2cyYXRoMFpaNi9mCkFHK1oxdDRCdTN0ZWFKL3VudmM2UHBVZCt5cElRZWtVSVRwc3lJZEdxZDM0MFBEVGkvTzA4ZEh4YjVTNTR0TzJDdGVYQ1Q0b0JuMDUKK3BrK25mM3lWYjZYNmdlRW9lS3dZUHUyeTZlNmxwbjRuaWdVRWl1VGxYWHUvMGd5cmUzdGJLbFAxdlJDbXJXeW5zMmZNbjF1cHZXagp5TTNZK0xVMmJzZmo5cXExYUxaL2R2OUYrdzFzbE44UEozOFA3d0FBQUFCSlJVNUVya0pnZ2c9PSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iTGF5ZXJfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiIHdpZHRoPSI0OHB4IiBoZWlnaHQ9IjQ4cHgiIHZpZXdCb3g9IjAgMCA0OCA0OCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAwIDAgNDggNDgiIHhtbDpzcGFjZT0icHJlc2VydmUiPiAgPGltYWdlIGlkPSJpbWFnZTAiIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgeD0iMCIgeT0iMCIKICAgIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBREFBQUFBd0NBTUFBQUJnM0FtMUFBQUFCR2RCVFVFQUFMR1BDL3hoQlFBQUFDQmpTRkpOCkFBQjZKZ0FBZ0lRQUFQb0FBQUNBNkFBQWRUQUFBT3BnQUFBNm1BQUFGM0NjdWxFOEFBQUJsVkJNVkVXVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVAp4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUCnhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlQKeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgyVHhIMlR4SDJUeEgzLy8vK0hoT2pjQUFBQQpoWFJTVGxNQUFqbDZydFh1K3RhdmZUc0RHSVRpNVlrY0VaRDMrWllUVk9uY2tWWXVFZ1JWMnV4YmxmNDhBYXo5bXdVSnM5STN6N2NMCm1BZ0hsSGR4bVZseVdCU1g2OUhRSGZpSTVqb1ZzQWJrMjdXb2szdWpWeS9VSCtFaUN0OGc3WUNCTVlPdGhYZzRoK0EyUHo2S0YvWkIKaGowYWpSRG9vSjNuRDFGL29aeXgxN0tPUUZBdzZublQwWXNkZndBQUFBRmlTMGRFaG96ZU8xMEFBQUplU1VSQlZFakgzWlg1UXhKQgpGTWVIQlFFVkxST0pVbUROUUNLUURvWEsxRXpKMUF4TE0rd1FPN0JESXp2VUxzdU83Ly9kRzFiMm1OMkJuK3Y5d3J6dis3eVp4OXUzCnM0ejlqK1pTM0o0V3I4L245YmUydFFlYTRoMmRSMkN5bzEzSEd1TGR3UjRJRmpvZWx2TW5UbktrdHk4U2phbHFMTm9mUE1YOWdkTVMKWEkxVE5ORTZtRFJweXBrVWlXZlRUbnhtaUVMWmRsRStkNTdrQ3hmdGZKcnp3eVAyUUM3UE0reG5ERk01bDV4cnZad0Fyb2ppS0cwago0Um03U3NFeHF6UStBRXpJMjBmdHVHYnQ3Z1F3T1NKUHlGMEg0bVpoS29TVXdocVlrc0swK1psM0FSNEpHdFA2NHdFS2hxamVBR2FjCitadloyVG4rT3dQTUc1TTRDTnhLT3ZPVHdFS09Gc2xld0NpNkRRaEs5cWVHM2xiNXNnZ3M2dm9zRUpIdGp6dGFKWGZOZjlNUFJKdncKYkFsWTFpTmVvRnRiamQrVDhDeE1jNjZIZkVENmtGbTViK0cxK3JuTjBidWtKNFNBV3U5S3hLdytPRHpMc3IrUThMQmUwaVBVTTBUZQpXbElMc0tTdEhoUEdxeExxSVZ1anQwdDNQTWIwbG10bjJQYXZ6Zis2N3JpQlluMzloR2RrYlR5ZjhLZTY4NHdZZlRTZWE5ZUx3Q2NyCndJYnV1ZWp5ZXFGN0JRZWV2UVFxTHNQdEJJWU03NVdkWjNSRmxFM3U2MDFneTNEZldQckRyWnBBejF1ekVBVDhKY04xQ1h5SnBtM2IKb3J4N0QzeGdVdnNJN094YXBUMjZlejdKZUdvNzlrU1JpcEpsdUdtelBwc2FvTWVOenlVN252bENnYStxUFpEakdkKzJSTG02VFBKKwp4dW5rd0hjNk9ySHd3M1FkSkt2N3BDR3ZNbWM3Mk9FUHVSSWZYUXVuMCtHZlkvbFY3ditLTUtudGJtK0tuNnpwWW93MXNvN3lpaG1mCkx6VCtLSEp6YmZ4ZXozcERJZThmejZMUy9MUDdMOXBmbUk3WEwwUmhuRzRBQUFBQVNVVk9SSzVDWUlJPSIgLz4KPC9zdmc+Cg==" style="height:24px;"></td></tr>
  </tbody>
  <tfoot class="gt_sourcenotes">
    <tr>
      <td class="gt_sourcenote" colspan="6"><strong>Source:</strong> Data from plantTraits of the Cluster package.</td>
    </tr>
  </tfoot>
  
</table>
</div><!--/html_preserve-->

<br />

****

## Example of table with all elements as icons

Make customized images for each element in illustrator (elementsToExport.ai).
* Name the files differently depending if these are column names, row names or content. 

<br />

* Replacing all elements as icons requires some data wrangling given the transforming function doesn't work for column names


```r
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


```r
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

<!--html_preserve--><div id="uvxcdpmbyk" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>@import url("https://fonts.googleapis.com/css2?family=Mina:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
html {
  font-family: Mina, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#uvxcdpmbyk .gt_table {
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

#uvxcdpmbyk .gt_heading {
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

#uvxcdpmbyk .gt_title {
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

#uvxcdpmbyk .gt_subtitle {
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

#uvxcdpmbyk .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#uvxcdpmbyk .gt_col_headings {
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

#uvxcdpmbyk .gt_col_heading {
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

#uvxcdpmbyk .gt_column_spanner_outer {
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

#uvxcdpmbyk .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#uvxcdpmbyk .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#uvxcdpmbyk .gt_column_spanner {
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

#uvxcdpmbyk .gt_group_heading {
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
}

#uvxcdpmbyk .gt_empty_group_heading {
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

#uvxcdpmbyk .gt_from_md > :first-child {
  margin-top: 0;
}

#uvxcdpmbyk .gt_from_md > :last-child {
  margin-bottom: 0;
}

#uvxcdpmbyk .gt_row {
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

#uvxcdpmbyk .gt_stub {
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

#uvxcdpmbyk .gt_stub_row_group {
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

#uvxcdpmbyk .gt_row_group_first td {
  border-top-width: 2px;
}

#uvxcdpmbyk .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#uvxcdpmbyk .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#uvxcdpmbyk .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#uvxcdpmbyk .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#uvxcdpmbyk .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#uvxcdpmbyk .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#uvxcdpmbyk .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#uvxcdpmbyk .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#uvxcdpmbyk .gt_footnotes {
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

#uvxcdpmbyk .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#uvxcdpmbyk .gt_sourcenotes {
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

#uvxcdpmbyk .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#uvxcdpmbyk .gt_left {
  text-align: left;
}

#uvxcdpmbyk .gt_center {
  text-align: center;
}

#uvxcdpmbyk .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#uvxcdpmbyk .gt_font_normal {
  font-weight: normal;
}

#uvxcdpmbyk .gt_font_bold {
  font-weight: bold;
}

#uvxcdpmbyk .gt_font_italic {
  font-style: italic;
}

#uvxcdpmbyk .gt_super {
  font-size: 65%;
}

#uvxcdpmbyk .gt_two_val_uncert {
  display: inline-block;
  line-height: 1em;
  text-align: right;
  font-size: 60%;
  vertical-align: -0.25em;
  margin-left: 0.1em;
}

#uvxcdpmbyk .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#uvxcdpmbyk .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#uvxcdpmbyk .gt_slash_mark {
  font-size: 0.7em;
  line-height: 0.7em;
  vertical-align: 0.15em;
}

#uvxcdpmbyk .gt_fraction_numerator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: 0.45em;
}

#uvxcdpmbyk .gt_fraction_denominator {
  font-size: 0.6em;
  line-height: 0.6em;
  vertical-align: -0.05em;
}
</style>
<table class="gt_table">
  <thead class="gt_header">
    <tr>
      <th colspan="6" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Subsample of plants traits dataset</th>
    </tr>
    
  </thead>
  
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMi41IiB5PSIzIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjgwIiByeD0iNC41OSIvPjx0ZXh0IGNsYXNzPSJjbHMtMiIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMjEuMjUgNDguNjIpIj5TcGVjaWVzPC90ZXh0Pjwvc3ZnPg==" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDE4LjkyIDM3LjE4KSI+V29vZHk8dHNwYW4geD0iMTEuMTIiIHk9IjI0Ij5wbGFudDwvdHNwYW4+PC90ZXh0Pjwvc3ZnPg==" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDI2LjkgMzcuMTkpIj5MZWFmeTx0c3BhbiB4PSIyLjk0IiB5PSIyNCI+cGxhbnQ8L3RzcGFuPjwvdGV4dD48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjI0cHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDExLjc5IDM5Ljc1KSI+U3VtbWVyPHRzcGFuIHg9IjkuOTciIHk9IjI0Ij5hbm51YWw8L3RzcGFuPjwvdGV4dD48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjIycHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDIzLjAzIDI1LjA4KSI+TGVhdmVzPHRzcGFuIHg9Ii0wLjkxIiB5PSIyMyI+YWx3YXlzPC90c3Bhbj48dHNwYW4geD0iLTE1LjcxIiB5PSI0NiI+ZXZlcmdyZWVuPC90c3Bhbj48L3RleHQ+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojYWRhYzlmO30uY2xzLTJ7Zm9udC1zaXplOjIycHg7ZmlsbDojZmZmO2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iMyIgeT0iMyIgd2lkdGg9IjExMCIgaGVpZ2h0PSI4MCIgcng9IjQuNTkiLz48dGV4dCBjbGFzcz0iY2xzLTIiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDMyLjUxIDI4LjU0KSI+V2luZDx0c3BhbiB4PSItMjIuNTgiIHk9IjIzIj5kaXNwZXJzZWQ8L3RzcGFuPjx0c3BhbiB4PSItMS43NyIgeT0iNDYiPmZydWl0czwvdHNwYW4+PC90ZXh0Pjwvc3ZnPg==" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTEsLmNscy0ye2ZpbGw6I2FkYWM5Zjt9LmNscy0ye2ZvbnQtc2l6ZToyM3B4O2ZvbnQtZmFtaWx5Ok1pbmEtQm9sZCwgTWluYTtmb250LXdlaWdodDo3MDA7fTwvc3R5bGU+PC9kZWZzPjxwYXRoIGNsYXNzPSJjbHMtMSIgZD0iTTExNy4zNSwzSDcuNjVBNC44OSw0Ljg5LDAsMCwwLDIuNSw3LjU5Vjc4LjQxQTQuODksNC44OSwwLDAsMCw3LjY1LDgzaDEwOS43YTQuODksNC44OSwwLDAsMCw1LjE1LTQuNTlWNy41OUE0Ljg5LDQuODksMCwwLDAsMTE3LjM1LDNaTTExOCw3NC40MUE0Ljg5LDQuODksMCwwLDEsMTEyLjg3LDc5SDEyLjEzQTQuODksNC44OSwwLDAsMSw3LDc0LjQxVjExLjU5QTQuODksNC44OSwwLDAsMSwxMi4xMyw3SDExMi44N0E0Ljg5LDQuODksMCwwLDEsMTE4LDExLjU5WiIvPjx0ZXh0IGNsYXNzPSJjbHMtMiIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTUuMjIgNDcuOTIpIj5TcGVjaWVzIDE8L3RleHQ+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNDkgNDcuOTYpIj5TcGVjaWVzIDI8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNzQgNDcuOTIpIj5TcGVjaWVzIDM8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTEuODggNDcuOTIpIj5TcGVjaWVzIDQ8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNDYgNDcuOTIpIj5TcGVjaWVzIDU8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMzMgNDcuOTIpIj5TcGVjaWVzIDY8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuNzIgNDcuOTIpIj5TcGVjaWVzIDc8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMjggNDcuOTIpIj5TcGVjaWVzIDg8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTIuMzcgNDcuOTIpIj5TcGVjaWVzIDk8L3RleHQ+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNMTE3LjM1LDNINy42NUE0Ljg5LDQuODksMCwwLDAsMi41LDcuNTlWNzguNDFBNC44OSw0Ljg5LDAsMCwwLDcuNjUsODNoMTA5LjdhNC44OSw0Ljg5LDAsMCwwLDUuMTUtNC41OVY3LjU5QTQuODksNC44OSwwLDAsMCwxMTcuMzUsM1pNMTE4LDc0LjQxQTQuODksNC44OSwwLDAsMSwxMTIuODcsNzlIMTIuMTNBNC44OSw0Ljg5LDAsMCwxLDcsNzQuNDFWMTEuNTlBNC44OSw0Ljg5LDAsMCwxLDEyLjEzLDdIMTEyLjg3QTQuODksNC44OSwwLDAsMSwxMTgsMTEuNTlaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZTllOGU0O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td></tr>
    <tr><td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMjUgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7Zm9udC1zaXplOjIzcHg7Zm9udC1mYW1pbHk6TWluYS1Cb2xkLCBNaW5hO2ZvbnQtd2VpZ2h0OjcwMDt9LmNscy0xLC5jbHMtMntmaWxsOiNhZGFjOWY7fTwvc3R5bGU+PC9kZWZzPjx0ZXh0IGNsYXNzPSJjbHMtMSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoNy45IDQ3LjkyKSI+U3BlY2llcyAxMDwvdGV4dD48cGF0aCBjbGFzcz0iY2xzLTIiIGQ9Ik0xMTcuMzUsM0g3LjY1QTQuODksNC44OSwwLDAsMCwyLjUsNy41OVY3OC40MUE0Ljg5LDQuODksMCwwLDAsNy42NSw4M2gxMDkuN2E0Ljg5LDQuODksMCwwLDAsNS4xNS00LjU5VjcuNTlBNC44OSw0Ljg5LDAsMCwwLDExNy4zNSwzWk0xMTgsNzQuNDFBNC44OSw0Ljg5LDAsMCwxLDExMi44Nyw3OUgxMi4xM0E0Ljg5LDQuODksMCwwLDEsNyw3NC40MVYxMS41OUE0Ljg5LDQuODksMCwwLDEsMTIuMTMsN0gxMTIuODdBNC44OSw0Ljg5LDAsMCwxLDExOCwxMS41OVoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZjRlZmVmO30uY2xzLTJ7ZmlsbDojZWI5OTk5O308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0LjU5Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNDcuNjksNTYuMiw1OCw0NS44OSw2OC4zMSw1Ni4ybDIuODktMi44OUw2MC44OSw0Myw3MS4yLDMyLjY5LDY4LjMxLDI5LjgsNTgsNDAuMTEsNDcuNjksMjkuOCw0NC44LDMyLjY5LDU1LjExLDQzLDQ0LjgsNTMuMzFaTTU4LDcwLjVhMjYuNTMsMjYuNTMsMCwwLDEtMTAuNjYtMi4xN0EyNy43MSwyNy43MSwwLDAsMSwzMi42Nyw1My42NmEyNy40MiwyNy40MiwwLDAsMSwwLTIxLjM4LDI3LjQzLDI3LjQzLDAsMCwxLDUuOTEtOC43NCwyOC4yNiwyOC4yNiwwLDAsMSw4Ljc2LTUuODcsMjcuNDQsMjcuNDQsMCwwLDEsMjEuMzksMCwyNy4zNCwyNy4zNCwwLDAsMSwxNC42LDE0LjYxLDI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTJhMjIuNTEsMjIuNTEsMCwwLDAsMTYuNTctNi44NUEyMi41NywyMi41NywwLDAsMCw4MS4zOCw0MywyMy4yNSwyMy4yNSwwLDAsMCw1OCwxOS42MiwyMy4zLDIzLjMsMCwwLDAsMzQuNjMsNDNhMjIuNTIsMjIuNTIsMCwwLDAsNi44NCwxNi41M0EyMi41MywyMi41MywwLDAsMCw1OCw2Ni4zOFoiLz48L3N2Zz4=" style="height:50px;"></td>
<td class="gt_row gt_center"><img src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMTYgODYiPjxkZWZzPjxzdHlsZT4uY2xzLTF7ZmlsbDojZWRmNGYwO30uY2xzLTJ7ZmlsbDojOTNjNDdkO308L3N0eWxlPjwvZGVmcz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjMiIHk9IjMiIHdpZHRoPSIxMTAiIGhlaWdodD0iODAiIHJ4PSI0Ii8+PHBhdGggY2xhc3M9ImNscy0yIiBkPSJNNTMuOTQsNTUuNTEsNzMuNCwzNi4wNiw3MC4yNCwzM2wtMTYuMywxNi4zTDQ1LjY5LDQxLDQyLjYsNDQuMVpNNTgsNzAuNWEyNi41MywyNi41MywwLDAsMS0xMC42Ni0yLjE3QTI3LjcxLDI3LjcxLDAsMCwxLDMyLjY3LDUzLjY2YTI3LjQyLDI3LjQyLDAsMCwxLDAtMjEuMzgsMjcuNDMsMjcuNDMsMCwwLDEsNS45MS04Ljc0LDI4LjI2LDI4LjI2LDAsMCwxLDguNzYtNS44NywyNy40MiwyNy40MiwwLDAsMSwyMS4zOCwwQTI3LjMxLDI3LjMxLDAsMCwxLDgzLjMzLDMyLjI4YTI3LjQyLDI3LjQyLDAsMCwxLDAsMjEuMzgsMjguMjYsMjguMjYsMCwwLDEtNS44Nyw4Ljc2LDI3LjQzLDI3LjQzLDAsMCwxLTguNzQsNS45MUEyNi42NSwyNi42NSwwLDAsMSw1OCw3MC41Wm0wLTQuMTNhMjIuNSwyMi41LDAsMCwwLDE2LjU3LTYuODRBMjIuNTYsMjIuNTYsMCwwLDAsODEuMzcsNDMsMjMuMjIsMjMuMjIsMCwwLDAsNTgsMTkuNjMsMjMuMywyMy4zLDAsMCwwLDM0LjYyLDQzYTIyLjUzLDIyLjUzLDAsMCwwLDYuODUsMTYuNTNBMjIuNTIsMjIuNTIsMCwwLDAsNTgsNjYuMzdaIi8+PC9zdmc+" style="height:50px;"></td></tr>
  </tbody>
  <tfoot class="gt_sourcenotes">
    <tr>
      <td class="gt_sourcenote" colspan="6"><strong>Source:</strong> Data from plantTraits of the Cluster package.</td>
    </tr>
  </tfoot>
  
</table>
</div><!--/html_preserve-->

 <br />

****

## Shiny with tables

- Input folder with icons where the names have a first string as "header" separated by underscore and the same string in the column header of the data. The row header icons should have the first string as the column name separated by underscore and then the matching string in the data. The content icons should have "content" separated by underscore and the string categories in the data.

- Input data in csv format

- Input the height to be used for the icons when plotting the table

 <br />
 
****

Make Input and output buttons and panels


```r
library(tidyverse)
library(here)
library(gt)
library(shiny)
library(shinyFiles)

ui <- fluidPage(
  titlePanel("Producing pretty tables with icons"),
  
  # Sidebar with two input widgets
  sidebarLayout(
    sidebarPanel(
      
      p("1. Select folder with design elements from illustrator"),
      p(""),
      shinyDirButton(id = "iconsFolder", label = "Select icons",
                     title = "Select directory with icons"), ### to add Icons
      p(""),
      p("2. Upload data file in csv format"),
      fileInput(inputId = "dataset",
                label = "Find file", accept = c(".csv")),       ### to add dataset
      p("3. Type height of the icons in pixels"), 
      numericInput("iconHeight", "Height", value = 30),
      br(),
      br(),
      br(),
      p("4. Export table as pdf"), 
      downloadButton("download", "table.pdf"),
      p("Exporting function doesn't export as the html version.\nIncrease icon height until row padding is more suitable.")),      
    
    mainPanel(
      h5("\nListed icons"), 
      gt_output("icons"),
      h5("Raw table"), 
      tableOutput("table0"),
      br(),
      h5("\nPretty table"), 
      gt_output(outputId = "Table"),
      p("\n")
    ) 
  ),
)

server <- function(input, output, session){
  ## select folder with design elements
  volumes = c(wd=here())
  
  shinyDirChoose(input, 'iconsFolder', roots = volumes, 
                 filetypes = 'svg')
  
  icons0 <- reactive({
    data.frame(icons = list.files(parseDirPath(volumes, input$iconsFolder), 
                                         pattern = "svg", full.names = TRUE)) %>%
      mutate(columns = basename(tools::file_path_sans_ext(icons))) %>%
      filter(str_detect(columns, "_")) %>%
      separate(columns, into = c("column","content"), sep = "_", extra = "drop",
               remove = TRUE, fill = 'left')
    })
  
  output$icons <- render_gt(height = px(200),{
    gt(icons0()) %>%
      text_transform(locations = cells_body(columns = icons, rows = everything()),
                     fn = function(x) { map_chr(x, ~ local_image(filename = .x,
                                                                 height = input$iconHeight))})   ### <-
    
  })
  
  ## read data input file and makes it a reactive element
  input_dataset <- reactive({
    req(input$dataset)   ### <-
    read.csv(input$dataset$datapath, 
             na.strings = "NA",
             colClasses = "character")
  })
  
  output$table0 <- renderTable(input_dataset())
    
  tableOut <- reactive({
    if (is.null(input_dataset)) {
      return(NULL)}
    
    icons <- icons0() 
    data0 <- input_dataset() 
    
    rowHeader <- icons %>% 
      filter(!column %in% c('content','header')) %>% 
      pull(column) %>% 
      unique()
    
   if(length(rowHeader) == 1){ # make sure there are icons for only one row header

      # prepare column header
      colData <- data.frame(content = colnames(data0)) %>%
        left_join(filter(icons, column %in% 'header'), by = "content") %>%
        pivot_wider(names_from = content, values_from = icons) %>%
        select(-column)
  
      # prepare row header
      rowData <- data.frame(content = pull(select(data0, !!as.symbol(rowHeader)))) %>%
        left_join(filter(icons, column %in% rowHeader), by = "content") %>%
        rename(!!rowHeader := "icons") %>%
        select(-column, -content)

      # prepare content
      data1 <- data0 %>%
        select(-!!as.symbol(rowHeader)) %>%
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

      
   gt(dataIcons) %>%
     opt_table_font(font = list(google_font("Mina"), default_fonts())) %>%
     text_transform(locations = cells_body(columns = everything(), rows = everything()),
                    fn = function(x) { map_chr(x, ~ local_image(filename = .x,
                                                                height = input$iconHeight))}) %>%  ### <-
     tab_style(
       style = "padding:0px;",
       locations = cells_body(columns = everything(), rows = everything())
     ) %>%
     tab_options(column_labels.hidden = TRUE, ## remove header without icons paths
                 table.border.top.style = "hidden",
                 table.border.bottom.style = "hidden",
                 table_body.hlines.style = "hidden")
   }
  })
  
  output$Table <- render_gt({
    tableOut()
  })
  
  output$download <- downloadHandler(
    filename = function() {
      here("table.pdf")
    } ,
    content = function(file1) {
      gtsave(tableOut(), file1, vwidth = input$iconHeight*(nrow(input_dataset())/2)) #, vheight = input$iconHeight*0.1 <- doesn't do anything
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
```

****

### Shiny app that is not working on github


```r
shinyAppFile(
  here('app.R'),
  options = list(width = "100%", height = 800)
)
```

<img src="figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />



