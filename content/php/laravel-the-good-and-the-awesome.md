---
date: 2013-01-17T11:47:00Z
title: "Laravel, The Good and The Awesome"
type: post
aliases:
  - /web-development/laravel-the-good-and-the-awesome/
---

PHP frameworks are all over the web currently with new ones cropping up more and more. We have the golden oldies with [Zend][zend], [CodeIgniter][codeigniter] and [CakePHP][cakephp] but now we are also faced with the new kids on the block with [Symfony][symfony] and todays topic - [Laravel][laravel].

This is a bit of a strange first post for myself as a Ruby (and Rails) developer but _development is development is development_ and Laravel is a hot topic in PHP currently.

When I tried Laravel it was version 3.2.12 and there is lots in the pipeline so things may change.

## So what's special about it?

I enjoy flexibility and so initially I had always quite liked the _separation of concerns_ found in the Zend library. Being able to pull parts of an app out and plug it in elsewhere is awesome. I have dabbled with other frameworks but this is often where I feel many fall down.

Being able to switch core pieces of an application is brilliant and having that sort of access to a well-written codebase can help teach you a lot about some of the smarter decisions made by the developers.

Laravel is well-written and very flexible. Nothing is done using magic and fairy dust just good design decisions and an aim to make the framework a solid collection of testable classes.

Unlike Zend I find that the way the pieces of the framework fit together is much more intuitive.

### Awesome features for a PHP framework

Laravel was built to be cutting-edge. It uses the latest greatest stuff in PHP such as closures and namespaces. Doing away with older PHP versions is a perfect decision for new frameworks. The language is changing rapidly now making some good decisions (finally).

They have done away with the typical /controller/action/param routing style which I couldn't recommend more. It's a little more verbose because of this but it is an extra layer of control. I have always disagreed with the URL having to be a direct interface to your classes.

The framework comes with a built in templating system called blade which is easy to use. I question if layouts could be done in a more traditional way but hey it works.

Another feature I adore is the _Object Relational Mapper_. It works well and many will tell you that an ORM is bloat and can slow down your code. I disagree. Yes the queries may be less optimised and may occur more than hand crafted SQL but the awesome-sauce is found in the development time saved when using one.

### The not so good

_Statics_. A constantly [debated][debate] addition to PHP. I don't think anyone disagrees with its inclusion but the use of them is often a discussion point amongst the modern PHP dev.

I don't like the over use of static methods. Even when it comes to helpers I believe there is often an argument that they can be instances that are made available to the view.

Many of the examples also place code examples directly into the routes. __Please don't do this__. Controllers were built to handle this. It may be quicker to demonstrate the use of a class or two but it is not a decision that helps build a maintainable application.

_**EDIT:** Since writing this I have been made aware that **Laravel 4** leverages a [brilliant IoC Container][ioc] which allows you to pass arguments to your application components of custom interfaces. You simply implement the interfaces and then tell your app what Class to use when that implementation is required. Now this is brilliant for creating testable, decoupled code._

### Why use it?

To be frank, Laravel is a strong choice for those looking for a PHP web framework. Its use of the modern language and flexibility make it one of the most customisable. Its design choices encourage re-use and a complete object orientated approach to PHP.

[zend]: http://framework.zend.com/ "Zend Framework"
[codeigniter]: http://ellislab.com/codeigniter "CodeIgniter"
[cakephp]: http://cakephp.org/ "CakePHP"
[symfony]: http://symfony.com/ "Symonfy"
[laravel]: http://laravel.com/ "Laravel"
[debate]: http://www.reddit.com/r/PHP/comments/10hank/avoid_static_methods_at_all_costs_testability/ "Debate on Reddit"
[ioc]: http://vimeo.com/53029232 "Laravel 4 IoC Container"
