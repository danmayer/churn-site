amacs churn-site
===

A app to calculate and display churn on a project.

## To Run Examples Locally

    foreman start
    #or
    bundle exec rackup -p 3000
    #or with dev procfile for shotgun reloading
    foreman start -f Procfile.dev -e prod.env
    #or local with production data (make sure red is and other env vars are set)
    RACK_ENV=production foreman start -f Procfile

## TODO

* fix issues with class and method level churn
* caching or speed up the graph rendering
* clean up / refactoring
* test coverage
* travis-ci
* build a working heroku console that loads all the right classes

## Contributing

1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "Added something awesome, it does X which solves problem Y")
4. Push to the branch (git push origin my_markup)
5. If you haven't already read about good [Pull Request practices](http://codeinthehole.com/writing/pull-requests-and-other-good-practices-for-teams-using-github/) or have never submitted one before read about submitting [your first pull request](http://jumpstartlab.com/news/archives/2013/04/15/your-first-pull-request)
6. Open a [Pull Request](https://help.github.com/articles/using-pull-requests)
7. Awesome thanks I will try to get back to you soon.

## MIT License

See the file license.txt for copying permission.

#### Generated by Sinatra Template

This project was originally generated by [sinatra template](https://github.com/danmayer/sinatra_template)
