# Site generator for kumanofes2020

## How to Generate HTMLs
1. First of all, install `bundler` on your system.
1. Next, install imagemagick by `sudo apt-get install libmagick++-dev`
1. Run commands bellow. (in the top directory of this repository)
```
$ bundle install --path=vendor/bin
$ git clone https://github.com/kumano-dormitory/Kumanofes2019data.git
$ mv Kumanofes2019data data
$ bundle exec ruby build.rb
```
1. Then, you will see HTMLs in the `_site` directory.

## How to Check HTML Layout
```
$ bundle exec ruby server.rb
```
Now you can access `localhost:8000/ryosai2020` using web browser
