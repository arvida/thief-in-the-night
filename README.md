thief-in-the-night
==================

Heroku dyno auto scaler on the cheap. For use with the Heroku Scheduler addon or something cron like.

## Setup

First create a new Heroku app. 

Add the following add-ons to your new app:

* [Mandrill by MailChimp Starter](https://addons.heroku.com/mandrill) 
* [Heroku Scheduler](https://addons.heroku.com/scheduler)

Add your [Heroku API key](https://devcenter.heroku.com/articles/platform-api-quickstart#authentication) as a config variable:

  $ heroku config:add HEROKU_API_KEY=xxx
	
Add a e-mail to send error reports to if the scaling fails:

	$ heroku config:add ERROR_REPORT_EMAIL=hello@example.com
	
Go to the [Heroku Sceduler config page](https://heroku-scheduler.herokuapp.com/dashboard) and set up jobs to scale your dynos: 

```bash
ruby heroku-scaler.rb -a dat-app -t web -d 3 # scale web dynos to 3 for the app dat-app
```

```bash
ruby heroku-scaler.rb -a dat-app -t worker -d 1 # scale worker dynos to 1  for the app dat-app
```
