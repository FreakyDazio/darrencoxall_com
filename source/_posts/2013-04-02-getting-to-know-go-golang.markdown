---
layout: post
title: "Getting to know Go (Golang)"
date: 2013-04-02 08:00
comments: true
categories: web-development
---

Being ever on the lookout for cool technologies, I stumbled upon the wonderful new *language* '[Go][golang]'. Developed by Google as a means of combatting the flaws and shortcomings of current languages such as Java and C++ when it comes to highly concurrent requirements.

<!-- more -->

Go *(or Golang as it is often referred to)* is a strong typed, compiled language. It was built from the ground up for concurrency and thread-safety support. The brilliant standard library utilises this and in doing so makes it extremely easy to  develop concurrent applications.

There are numerous *hard-edge* decisions made with the language including the very C like object system and a unique function visibility system. Go is an object orientated language but the method/function definitions are much more explicit...

``` go Example Go Method Definition
// DoSomething operates on an object of type MyObject
// and accepts a string parameter.
// The function will return a boolean.
func (obj MyObject) DoSomething(name string) (bool) {
  // ...
}
```

The system used to determine function visibility is also *different* to the tried and tested. Functions and variables that begin with a lowercase character are only accessible within their package whereas those beginning with an uppercase character are usable elsewhere.

## What am I doing with Go?

I am currently in the process of writing a web application consisting of an API and a JavaScript front-end. I was leaning towards using Ruby on Rails but when I am just creating an API many of the features provided by Rails are un-necessary. It brings with it a larger overhead. I have always been aware of this but it wasn't until I saw a [recent benchmark][benchmark] that I was encouraged to look elsewhere, after all, I should be selecting the best tool for the job not forcing my favourite tool to do everything. The results of the benchmark gave me an excuse to check out Go.

*Before any complaints - I will be the first to say comparing Go to Rails is un-fair. Rails is a framework and Go is a language. I know this but it still allows me to question if a large framework is needed on a project that has just a single JSON API. I decided the answer was No.*

## My opinions & thoughts

Coming from a Ruby background Go was certainly a big change but I like a good challenge. It is easy to forget how much is handled for you when using a large framework such as Rails. Go does very little for you. Even with a fantastic standard library and brilliant documentation, there is a lot more to be done in Go to create a working web application.

There is a benefit to working from the core up. You get 100% control over which features you include and how much configuration your application *actually* requires. Go will even go as far as formatting your code so the real development time is spent designing and implementing your application. There are no frameworks that you have to work around.

By developing in this way using Go you can gain massive [performance improvements][performance] and start leveraging modern hardware using concurrency.

I am really enjoying Go and I hope to continue developing with it in the future. It doesn't feel like a language designed for traditional web applications such as Rails but it does have many strengths that make it a much better option for more streamlined services.

### Closing Comments

I hope this article does highlight why as developers we should be looking to constantly learn. We shouldn't have a single language or framework that we believe has everything because it frankly doesn't exist. The best tool is completely opinionated and is determined by the project and the environment in which it is developed.

Oh… And Go is super cool and quick. Remember that it is a language and isn't designed for just web applications but *applications* in general.

**EDIT:** I have created a basic vagrant repository that can help people by installing and preparing a golang environment. Check out [vagrant-golang][vagrant_golang]

[golang]: http://golang.org/ "Golang"
[benchmark]: http://www.techempower.com/blog/2013/03/28/framework-benchmarks/ "Framework Benchmarks"
[performance]: http://blog.iron.io/2013/03/how-we-went-from-30-servers-to-2-go.html "Performance Improvements using Go"
[vagrant_golang]: https://github.com/FreakyDazio/vagrant-golang "FreakyDazio/vagrant-golang"
