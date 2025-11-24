# README

This app is a demo Rails app showing how to work with Cocoon using the Simple_form
nd Bootstrap 4 apps.

It is setup using Ruby version 2.6.6 and Rails version 5.2.4.  It also uses the PG database app, so it needs a working Postgresql environment.

RSpec is the testing method.

It uses 4 models: Season, Weeks, Games, and Teams.

Season is a season in an NFL game. It has many weeks.

Weeks is a week within in a season. It has many games and belongs to a season.

Games is a game withing a week.  It belongs to a week.

Teams is a list of all of the teams in the NFL.
