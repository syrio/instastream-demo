# A SocketStream implementation of Realtime-Demo
========================================================================

The good people at [Instagram](http://www.instagram.com) created this beautiful [demo](http://demo.instagram.com) and [released](https://github.com/Instagram/Realtime-Demo) it a while back. 
In his excellent [blog post](http://blog.carbonfive.com/2011/06/14/instagram-realtime-demo-with-node-js-redis-and-web-sockets/), [asalant](https://github.com/asalant/) described his [fixes](https://github.com/asalant/Realtime-Demo) to the project and how to use it.
After reading the source code I noticed that it's possible to create a version of the demo that is based on the new [SocketStream](https://github.com/socketstream/socketstream/) platform. Given the lack of SocketStream demos, I decided this could be a minor contribution for anyone interested in the platform.

## Major differences from Realtime-Demo

1. Uses SocketStream Redis-based PubSub instead of directly using Redis PubSub,
2. A simple Cakefile that replaces having to use cUrl for working against the Instagram API.
3. It doesn't use express and instead uses the connect middleware capabilities provided by SocketStream v0.2
4. It doesn't use environment variables for providing configuration to the server.
5. It's in CoffeeScript.

## Installation

1. Install socketstream v0.2 and it's dependencies
2. Clone instastream-demo


## Usage

### Filling your host and your Instagram API client details

  1. Open the application configuration file - instastream-demo/config/app.coffee
  2. Add your Insatgram client\_id and client\_secret to instagram.api.client\_id and instagram.api.client\_secret
  3. If you wish to use the Cakefile, add your external host and port to http.external.host and http.external.port (this is the callback url that Instagram API servers will dispatch media to)

### Starting the server

      % $YOUR_REDIS_PATH/src/redis-serer
      % cd instastream-demo
      % socketstream start


## Cakefile

### Watch all default cities

While the socketstream server is running:

      % cd instastream-demo
      % cake all

### Watch a certain default city

While the socketstream server is running:

      % cd instastream-demo
      % cake -w 'London' watch

### List default cities

      % cd instastream-demo
      % cake list
  
### Watch a certain non-default city

While the socketstream server is running:

      % cd instastream-demo
      % cake -w "Rome" -t "41.9" -o "12.5" watch

If you want to add a city with a minus long or minus lat, use a double minus (avoids problems with optparse options parsing)

      % cd instastream-demo
      % cake -w "Philadelphia" -t "39.95" -o "--75.17"  watch

### Clear active subscriptions

      % cd instastream-demo
      % cake clear

## cUrl

If you don't like the Cakefile you can use cUrl - see the last section of the [blog post](http://blog.carbonfive.com/2011/06/14/instagram-realtime-demo-with-node-js-redis-and-web-sockets/) and the Instagram API [documentation](http://instagram.com/developer/) for information on how to do that.