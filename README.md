GemRequire
==========

`gem_require` is a Rubygems plugin which provides a cheap way to ensure that a gem is installed.

Install it like so:

    $ gem install gem_require
    Successfully installed gem_require-0.0.3
    1 gem installed

Now you can use "`gem require`" in place of "`gem install`".  It's similar, except that it short-circuits if you already have the required gem installed:

    $ gem require heroku
    heroku (1.11.0) is already installed

If you want to ensure that you're on the bleeding edge, use the "`--latest`" option:

    $ gem require --latest heroku
    Installing heroku (1.14.6) ...
    Installed heroku-1.14.6

Of course, if you already **have** the latest version, there's no need to re-install it:

    $ gem require --latest heroku
    heroku (1.14.6) is already installed

Enjoy.
