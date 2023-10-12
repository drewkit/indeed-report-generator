# Indeed Report Generator

## Setup Tool

Build the Docker image:

```
docker build -t indeed-report-generator .
```

## Define the search queries

Setup one or many data pulls / queries for a given PROJECT_NAME:

```
docker run --rm -it -v ${PWD}/projects:/scripts/projects indeed-report-generator ruby setup_data_pull.rb PROJECT_NAME 'job post title query' 80027
```

## Generate Report

Transform all your data pulls into a single csv report:

```
docker run --rm -it -v ${PWD}/projects:/scripts/projects indeed-report-generator ruby filter_results_of_data_set.rb PROJECT_NAME
```

Script will generate a csv file at `projects/PROJECT_NAME/report_in_progress.csv`. Go ahead and move the file into `projects/PROJECT_NAME/shared_reports` directory. Recommend renaming the file to the given date. Any job postings appearing in this csv file will be filtered out from future generated reports.


Upload generated report to google docs. Sort rows by job title column. Delete rows for jobs that you 

## Fetch updates from Indeed

The next time you want to pull data from indeed, use the following command to fetch with your established data pulls:

```
docker run --rm -it -v ${PWD}/projects:/scripts/projects indeed-report-generator ruby fetch_data_from_indeed.rb PROJECT_NAME
```

Run the generate report docker command to generate a new csv file based on the updated query results.

Add regular expression entries as desired to `projects/PROJECT_NAME/blacklist.yml`

Remove specific data pulls by simply deleting a given file in the `projects/PROJECT_NAME/pulled_data` directory.