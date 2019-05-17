0. Install `indeed-ruby` rubygem, [apply for publisher id](https://www.indeed.com/publisher) and set to `INDEED_REPORT_GENERATOR_PUBLISHER_ID` in your bash profile

1. Generate data pulls for project by providing project name, search query and zip code. Project folder will be generated. Repeat command for all search queries.

```
ruby setup_data_pull.rb PROJECT_NAME 'customer success engineer' 80027
```

2. Combine results of data pulls. Duplicates as well as regexed job title entries in `blacklist.yml` will be filtered out. `report_in_progress.csv` will output to project folder.

```
ruby filter_results_of_data_set.rb PROJECT_NAME
```

3. Rename csv and place in `shared_reports` folder. The `filter_results_of_data_set.rb` will filter out these job posts in future reports.

4. To refresh data pulls, run the following command and then recombine results with `filter_results_of_data_set.rb` script.

```
ruby fetch_data_from_indeed.rb PROJECT_NAME
```
