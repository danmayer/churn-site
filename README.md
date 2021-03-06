churn-site
===

A app to calculate and display code churn on a project.

This is a web front-end and hooks that trigger builds, but all the data is powered by the [churn gem](https://github.com/danmayer/churn)

It displays data like:

* total files with churn above threshold
* avg file, class, and method churn
* the number of files over the avg file, class, and method churn
* churn increase over time

[![Build Status](https://secure.travis-ci.org/danmayer/churn-site.png)](http://travis-ci.org/danmayer/churn-site)

## To Run Examples Locally

    foreman start
    #or
    bundle exec rackup -p 3000
    #or with dev procfile for shotgun reloading
    foreman start -f Procfile.dev -e .env.development
    #or local with production data (make sure redis and other env vars are set)
    RACK_ENV=production foreman start -f Procfile

## Console

    #local console
    bundle exec script/console
    
    #heroku remote console in production more
    heroku run script/heroku-console


## Api Docs

   The documentation for the churn api can be found at [churn api docs](http://churn.picoappz.com/docs).

## TODO

* allow project to submit churn data via churn gem pushing results to the server
  * This is done document it
* reduce dependancies and make it easier for people to run churn-site 
* setup heroku cron job to run rake tasks that calculates and caches avgs across all projects
* clean up / refactoring
* better test coverage
* better var management... (using dotenv to manage vars now follow https://devcenter.heroku.com/articles/config-vars for best env var management)
* query the most popular ruby projects on GH and run them through churn
  * https://github.com/search?l=ruby&q=stars%3A%3E3&s=forks&type=Repositories 

## Contributing

1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "Added something awesome, it does X which solves problem Y")
4. Push to the branch (git push origin my_markup)
5. If you haven't already read about good [Pull Request practices](http://codeinthehole.com/writing/pull-requests-and-other-good-practices-for-teams-using-github/) or have never submitted one before read about submitting [your first pull request](http://jumpstartlab.com/news/archives/2013/04/15/your-first-pull-request)
6. Open a [Pull Request](https://help.github.com/articles/using-pull-requests)
7. Awesome thanks I will try to get back to you soon.

## Thanks

* Awesome charts thanks to [chart.js](http://www.chartjs.org/docs/)

## MIT License

See the file license.txt for copying permission.

#### Generated by Sinatra Template

This project was originally generated by [sinatra template](https://github.com/danmayer/sinatra_template)
